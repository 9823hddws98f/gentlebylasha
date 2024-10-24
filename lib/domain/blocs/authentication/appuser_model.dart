import 'package:sleeptales/domain/blocs/user/app_user.dart';

class AuthUser {
  final String id;
  final String email;
  final String name;
  final String photo;

  const AuthUser(this.id, this.email, this.name, this.photo);

  static const empty = AuthUser('', '', '', '');

  bool get isEmpty => this == AuthUser.empty;
  bool get isNotEmpty => this != AuthUser.empty;

  AppUser toAppUser() => AppUser(
        id: id,
        email: email,
        name: name,
        photoURL: photo,
        createdAt: DateTime.now(),
      );
}
