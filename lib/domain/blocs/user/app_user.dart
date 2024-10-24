import 'dart:convert';

import 'package:flutter/foundation.dart';

class AppUser {
  final String id;
  final String? name;
  final String email;
  final DateTime createdAt;
  final String? language;
  final String? heardFrom;
  final List<String>? goals;
  final String? photoURL;

  const AppUser({
    required this.id,
    this.name,
    required this.email,
    required this.createdAt,
    this.language,
    this.heardFrom,
    this.goals,
    this.photoURL,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    String? language,
    String? heardFrom,
    List<String>? goals,
    String? photoURL,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      language: language ?? this.language,
      heardFrom: heardFrom ?? this.heardFrom,
      goals: goals ?? this.goals,
      photoURL: photoURL ?? this.photoURL,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.toUtc().millisecondsSinceEpoch,
      'language': language,
      'heardFrom': heardFrom,
      'goals': goals,
      'photoURL': photoURL,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      name: map['name'] != null ? map['name'] as String : null,
      email: map['email'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] as int,
        isUtc: true,
      ).toLocal(),
      language: map['language'] != null ? map['language'] as String : null,
      heardFrom: map['heardFrom'] != null ? map['heardFrom'] as String : null,
      goals:
          map['goals'] != null ? List<String>.from(map['goals'] as List<dynamic>) : null,
      photoURL: map['photoURL'] != null ? map['photoURL'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppUser.fromJson(String source) =>
      AppUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AppUser(id: $id, name: $name, email: $email, language: $language, heardFrom: $heardFrom, goals: $goals, photoURL: $photoURL)';
  }

  @override
  bool operator ==(covariant AppUser other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.email == email &&
        other.createdAt == createdAt &&
        other.language == language &&
        other.heardFrom == heardFrom &&
        listEquals(other.goals, goals) &&
        other.photoURL == photoURL;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      createdAt.hashCode ^
      language.hashCode ^
      heardFrom.hashCode ^
      goals.hashCode ^
      photoURL.hashCode;
}
