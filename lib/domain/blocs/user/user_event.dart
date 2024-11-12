part of 'user_bloc.dart';

abstract class UserEvent {
  const UserEvent();
}

class UserModified extends UserEvent {
  final AppUser user;

  const UserModified(this.user);
}

class UserUpdated extends UserEvent {
  final AppUser user;

  const UserUpdated(this.user);
}

class UserCreated extends UserEvent {
  final AppUser user;

  const UserCreated(this.user);
}

class UserLoaded extends UserEvent {
  final AppUser user;

  const UserLoaded(this.user);
}
