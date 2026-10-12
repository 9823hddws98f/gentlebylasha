import 'dart:convert';

import 'package:crypto/crypto.dart';

/// UUID-shaped id derived from the uid, passed to the store at purchase
/// (Apple appAccountToken, Google obfuscatedAccountId). The server checks it
/// to make sure a purchase belongs to the account. Must match accountToken()
/// in functions/src/entitlement.ts.
String accountToken(String uid) {
  final h = sha256.convert(utf8.encode(uid)).toString();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
      '${h.substring(16, 20)}-${h.substring(20, 32)}';
}
