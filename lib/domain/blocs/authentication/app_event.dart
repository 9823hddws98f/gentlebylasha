part of 'app_bloc.dart';

class AppEvent {
  const AppEvent();
}

class AppUserChanged extends AppEvent {
  final AuthUser user;

  const AppUserChanged(this.user);
}
