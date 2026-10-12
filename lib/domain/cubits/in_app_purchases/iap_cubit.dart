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
    if (!await _iapService.isAvailable()) {
      emit(state.copyWith(storeAvailable: false));
      return;
    }

    final response = await _iapService.queryProductDetails(productIds.toSet());
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

  Future<void> _onPurchaseDetailsReceived(List<PurchaseDetails> purchases) async {
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
          try {
            await _purchases.verifyPurchase(details);
            emit(state.copyWith(busy: false, error: IAPError.none));
          } on FirebaseFunctionsException catch (e) {
            debugPrint('verifyPurchase failed: ${e.code} ${e.message}');
            emit(state.copyWith(
              busy: false,
              error: e.message == 'linked-to-other-account'
                  ? IAPError.otherAccount
                  : IAPError.verificationFailed,
            ));
            // Leave the transaction open on temporary errors so the store
            // delivers it again; a purchase of another account never succeeds.
            if (e.message != 'linked-to-other-account') continue;
          } catch (e) {
            debugPrint('verifyPurchase failed: $e');
            emit(state.copyWith(busy: false, error: IAPError.verificationFailed));
            continue;
          }
      }
      // Finish only after the server has the purchase (or it can never be used).
      if (details.pendingCompletePurchase) {
        await _iapService.completePurchase(details);
      }
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
