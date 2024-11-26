import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '/domain/services/interfaces/in_app_purchases.dart';
import '/utils/get.dart';
import 'iap_service.dart';
import 'product.dart';

part 'iap_state.dart';

class IAPCubit extends Cubit<IAPState> {
  IAPCubit._() : super(const IAPState()) {
    _subscription = _iapService.purchaseStream.listen(_onPurchaseDetailsReceived);
    loadPurchases();
  }
  static final IAPCubit instance = IAPCubit._();

  final InAppPurchases _iapService = Get.the<InAppPurchases>();
  final _purchases = PurchasesApi.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  static const productIds = [
    'sleepytales_monthly_11.99',
    'sleepytales_annually_47.00',
  ];

  Future<void> loadPurchases() async {
    // Emit loading state while keeping existing data
    if (state.loaded) return;

    final isAvailable = await _iapService.isAvailable();
    if (!isAvailable) {
      emit(state.copyWith(errorMessage: 'In-app purchase is not available'));
      return;
    }

    final response = await _iapService.queryProductDetails(productIds.toSet());
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
      await _iapService.buyNonConsumable(purchaseParam);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onPurchaseDetailsReceived(List<PurchaseDetails> purchases) async {
    for (final details in purchases) {
      if (details.status == PurchaseStatus.purchased) {
        try {
          final purchaseVerified = await _purchases.verifyPurchase(details);
          if (purchaseVerified) {
            emit(state.copyWith(
              errorMessage: null,
              purchases: [...state.purchases, details],
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
      if (details.pendingCompletePurchase) {
        try {
          await _purchases.completePurchase(details);
          await _iapService.completePurchase(details);
          emit(state.copyWith(
            errorMessage: null,
            purchases: [...state.purchases, details],
          ));
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
