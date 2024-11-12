import 'dart:convert';

class AccountDeletionModel {
  final String id;
  final String userId;
  final String email;
  final String code;
  final DateTime createdAt;

  AccountDeletionModel({
    required this.id,
    required this.userId,
    required this.email,
    required this.code,
    required this.createdAt,
  });

  AccountDeletionModel copyWith({
    String? id,
    String? userId,
    String? email,
    String? code,
    DateTime? createdAt,
  }) {
    return AccountDeletionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      code: code ?? this.code,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'email': email,
      'code': code,
      'createdAt': createdAt.toUtc().millisecondsSinceEpoch,
    };
  }

  factory AccountDeletionModel.fromMap(Map<String, dynamic> map) {
    return AccountDeletionModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      email: map['email'] as String,
      code: map['code'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int, isUtc: true)
          .toLocal(),
    );
  }

  String toJson() => json.encode(toMap());

  factory AccountDeletionModel.fromJson(String source) =>
      AccountDeletionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AccountDeletionModel(userId: $userId, email: $email, code: $code, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant AccountDeletionModel other) {
    if (identical(this, other)) return true;

    return other.userId == userId &&
        other.email == email &&
        other.code == code &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return userId.hashCode ^ email.hashCode ^ code.hashCode ^ createdAt.hashCode;
  }
}
