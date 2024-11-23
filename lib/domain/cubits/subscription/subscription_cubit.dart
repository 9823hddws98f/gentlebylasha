import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'product.dart';
import 'subscription_service.dart';

part 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  static final SubscriptionCubit instance = SubscriptionCubit._();

  SubscriptionCubit._() : super(const SubscriptionInitial()) {
    _subscription = _inAppPurchase.purchaseStream.listen(_onPurchaseDetailsReceived);
    loadPurchases();
  }

  final _inAppPurchase = InAppPurchase.instance;
  final _cloudFunctions = SubscriptionService.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<void> loadPurchases() async {
    const productIds = ['sleepytales_monthly_11.99', 'sleepytales_annually_47.00'];

    // Emit loading state while keeping existing data
    if (state.loaded) return;

    final isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      emit(state.copyWith(
        errorMessage: 'In-app purchase is not available',
      ));
      return;
    }

    final response = await _inAppPurchase.queryProductDetails(productIds.toSet());
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Warning: Some ids where not found: ${response.notFoundIDs}');
    }

    emit(state.copyWith(
      products: response.productDetails.map((e) => PurchasableProduct(e)).toList(),
      errorMessage: null,
    ));
  }

  Future<void> purchaseProduct(ProductDetails productDetails) async {
    try {
      if (!state.loaded) return;

      emit(state.copyWith(errorMessage: null));

      final purchaseParam = PurchaseParam(productDetails: productDetails);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onPurchaseDetailsReceived(List<PurchaseDetails> purchaseDetails) async {
    for (final purchaseDetail in purchaseDetails) {
      if (purchaseDetail.status == PurchaseStatus.purchased) {
        emit(state.copyWith(purchases: [...state.purchases, purchaseDetail]));
      }
      if (purchaseDetail.pendingCompletePurchase) {
        emit(state.copyWith(errorMessage: null));

        try {
          final resp = await _cloudFunctions.verifyPurchase(purchaseDetail);
          if (resp.data['status'] == 200) {
            await _cloudFunctions.completePurchase(purchaseDetail);
            await InAppPurchase.instance.completePurchase(purchaseDetail);

            emit(state.copyWith(
              errorMessage: null,
              purchases: [...state.purchases, purchaseDetail],
            ));
          } else {
            throw Exception('Purchase verification failed');
          }
        } catch (e) {
          emit(state.copyWith(
            errorMessage: e.toString(),
          ));
        }
      }
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
