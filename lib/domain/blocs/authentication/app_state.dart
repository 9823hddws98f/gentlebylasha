part of 'app_bloc.dart';

class AppState {
  final AuthUser? user;

  const AppState({this.user});

  bool get isAuthenticated => user != null;
}
