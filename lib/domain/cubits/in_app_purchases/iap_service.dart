import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';

import '/utils/common_extensions.dart';

class PurchasesApi {
  static final PurchasesApi instance = PurchasesApi._();

  PurchasesApi._();

  String get _serverUrl => kDebugMode
      ? 'http://localhost:8080/'
      : 'https://gentle-backend-3joud9n-mezzlasha.globeapp.dev';

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<bool> verifyPurchase(PurchaseDetails details) async {
    final url = Uri.parse('$_serverUrl/verifypurchase');
    const headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    final response = await http.post(
      url,
      body: jsonEncode({
        'source': details.verificationData.source,
        'productId': details.productID,
        'verificationData': details.verificationData.serverVerificationData,
        'userId': _userId,
      }),
      headers: headers,
    );
    if (response.statusCode == 200) {
      'Successfully verified purchase'.logDebug();
      return true;
    } else {
      'failed request: ${response.statusCode} - ${response.body}'.logDebug();
      return false;
    }
  }

  Future<void> completePurchase(PurchaseDetails purchaseDetails) {
    // final purchaseId = Platform.isAndroid
    //     ? purchaseDetails.purchaseID?.split('.')[1]
    //     : purchaseDetails.purchaseID;
    throw UnimplementedError();
  }
}
