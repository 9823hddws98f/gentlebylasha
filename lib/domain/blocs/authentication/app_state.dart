part of 'app_bloc.dart';

enum AppStatus { authenticated, loading, unauthenticated }

class AppState {
  final AppStatus status;
  final AuthUser user;
  const AppState({
    this.status = AppStatus.unauthenticated,
    this.user = AuthUser.empty,
  });

  const AppState.loadingAuthentication(this.user) : status = AppStatus.loading;
  const AppState.authenticated(this.user) : status = AppStatus.authenticated;

  const AppState.unauthenticated()
      : status = AppStatus.unauthenticated,
        user = AuthUser.empty;
}

class AuthenticationInitial extends AppState {}
