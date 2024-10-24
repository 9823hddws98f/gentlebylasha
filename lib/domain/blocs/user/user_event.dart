part of 'user_bloc.dart';

abstract class UserEvent {
  const UserEvent();
}

class UserChanged extends UserEvent {
  final AppUser user;

  const UserChanged(this.user);
}

class UserModified extends UserEvent {
  final AppUser user;

  const UserModified(this.user);
}

class UserUpdated extends UserEvent {
  final AppUser user;

  const UserUpdated(this.user);
}

class UserDeleted extends UserEvent {
  final AppUser user;

  const UserDeleted(this.user);
}

class UserCreated extends UserEvent {
  final AppUser user;

  const UserCreated(this.user);
}

class UserLoaded extends UserEvent {
  final AppUser user;
  final AppBloc appbloc;

  const UserLoaded(this.user, this.appbloc);
}
