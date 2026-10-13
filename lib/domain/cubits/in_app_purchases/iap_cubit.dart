import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '/domain/services/interfaces/in_app_purchases.dart';
import '/helper/account_token.dart';
import '/utils/get.dart';
import 'iap_service.dart';
import 'product.dart';

part 'iap_state.dart';

/// Store purchases on iOS/Android. Premium itself is read from
/// `subscriptions/{uid}` by EntitlementCubit once the server has verified it.
class IAPCubit extends Cubit<IAPState> {
  IAPCubit._() : super(const IAPState());
  static final IAPCubit instance = IAPCubit._();

  final InAppPurchases _iapService = Get.the<InAppPurchases>();
  final _purchases = PurchasesApi.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Subscriptions the server verified in this session, as
  /// "uid subscriptionKey" (another account must verify again).
  final _verified = <String>{};

  static const monthlyId = 'gentle_premium_monthly';
  static const yearlyId = 'gentle_premium_yearly';
  static const productIds = [monthlyId, yearlyId];

  /// Starts handling store transactions. Called after sign-in, because the
  /// server ties every purchase to the signed-in account. Unfinished
  /// transactions are delivered again at this point and get re-verified.
  void start() {
    _subscription ??= _iapService.purchaseStream.listen(_onPurchaseDetailsReceived);
    loadProducts();
  }

  Future<void> loadProducts() async {
    if (state.loaded) return;
    final ProductDetailsResponse response;
    try {
      if (!await _iapService.isAvailable()) {
        emit(state.copyWith(storeAvailable: false));
        return;
      }
      response = await _iapService.queryProductDetails(productIds.toSet());
    } catch (e) {
      // e.g. iOS 13/14: in_app_purchase_storekit 0.4 only talks StoreKit 2 (iOS 15+).
      debugPrint('Store not available: $e');
      emit(state.copyWith(storeAvailable: false));
      return;
    }
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Store products not found: ${response.notFoundIDs}');
    }
    final products = response.productDetails.map(PurchasableProduct.new).toList()
      ..sort((a, b) => productIds.indexOf(a.id).compareTo(productIds.indexOf(b.id)));
    emit(state.copyWith(products: products, storeAvailable: true));
  }

  Future<void> purchaseProduct(ProductDetails productDetails) async {
    emit(state.copyWith(busy: true, error: IAPError.none));
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      await _iapService.buyNonConsumable(PurchaseParam(
        productDetails: productDetails,
        applicationUserName: uid == null ? null : accountToken(uid),
      ));
    } catch (_) {
      emit(state.copyWith(busy: false, error: IAPError.purchaseFailed));
    }
  }

  Future<void> restorePurchases() async {
    emit(state.copyWith(busy: true, error: IAPError.none));
    try {
      await _iapService.restorePurchases();
    } catch (_) {
      emit(state.copyWith(busy: false, error: IAPError.purchaseFailed));
      return;
    }
    // Restored purchases arrive on the purchase stream; if there are none,
    // nothing else will clear the busy state.
    Future.delayed(const Duration(seconds: 8), () {
      if (state.busy) emit(state.copyWith(busy: false));
    });
  }

  /// Batches are handled one after the other, so two batches with the same
  /// subscription don't both verify it.
  Future<void> _handling = Future.value();

  void _onPurchaseDetailsReceived(List<PurchaseDetails> purchases) {
    _handling = _handling.then((_) => _handlePurchases(purchases)).catchError((Object e) {
      debugPrint('Handling store transactions failed: $e');
    });
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    // A restore (and a renewal backlog) delivers many transactions of the same
    // subscription; group them so each subscription is verified once.
    final bySubscription =
        <String, ({StorePurchase purchase, List<PurchaseDetails> transactions})>{};
    for (final details in purchases) {
      switch (details.status) {
        case PurchaseStatus.pending:
          emit(state.copyWith(busy: true));
        case PurchaseStatus.canceled:
          emit(state.copyWith(busy: false));
        case PurchaseStatus.error:
          emit(state.copyWith(busy: false, error: IAPError.purchaseFailed));
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final purchase = StorePurchase.from(details);
          if (purchase != null) {
            bySubscription
                .putIfAbsent(purchase.subscriptionKey, () => (purchase: purchase, transactions: []))
                .transactions
                .add(details);
            continue; // finished after verification
          }
          debugPrint('Store transaction without an id: ${details.productID}');
      }
      await _complete(details);
    }
    if (bySubscription.isEmpty) return;

    var anyVerified = false;
    var error = IAPError.none;
    for (final (:purchase, :transactions) in bySubscription.values) {
      final result = await _verify(purchase, transactions);
      if (result == IAPError.none) {
        anyVerified = true;
      } else if (error == IAPError.none) {
        error = result;
      }
    }
    emit(state.copyWith(busy: false, error: anyVerified ? IAPError.none : error));
  }

  /// Verifies one subscription with the server and finishes its transactions.
  /// Restored transactions of a subscription verified earlier in this session
  /// are only finished.
  Future<IAPError> _verify(StorePurchase purchase, List<PurchaseDetails> transactions) async {
    final verifiedKey = '${FirebaseAuth.instance.currentUser?.uid} ${purchase.subscriptionKey}';
    final onlyRestored = transactions.every((d) => d.status == PurchaseStatus.restored);
    if (!(onlyRestored && _verified.contains(verifiedKey))) {
      try {
        await _purchases.verifyPurchase(purchase);
        _verified.add(verifiedKey);
      } on FirebaseFunctionsException catch (e) {
        debugPrint('verifyPurchase failed: ${e.code} ${e.message}');
        // A purchase of another account never succeeds: finish it. On other
        // errors leave it open so the store delivers it again.
        if (e.message != 'linked-to-other-account') return IAPError.verificationFailed;
        await _completeAll(transactions);
        return IAPError.otherAccount;
      } catch (e) {
        debugPrint('verifyPurchase failed: $e');
        return IAPError.verificationFailed;
      }
    }
    // Finish only after the server has the purchase.
    await _completeAll(transactions);
    return IAPError.none;
  }

  Future<void> _completeAll(List<PurchaseDetails> transactions) async {
    for (final details in transactions) {
      await _complete(details);
    }
  }

  Future<void> _complete(PurchaseDetails details) async {
    if (!details.pendingCompletePurchase) return;
    try {
      await _iapService.completePurchase(details);
    } catch (e) {
      debugPrint('completePurchase failed: $e');
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
