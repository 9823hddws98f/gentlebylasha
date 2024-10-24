part of 'user_bloc.dart';

class UserState {
  final AppUser user;

  const UserState(this.user);

  UserState copyWith({AppUser? user}) => UserState(user ?? this.user);
}

class UserInitial extends UserState {
  UserInitial()
      : super(AppUser(
          id: '',
          email: '',
          createdAt: DateTime.now(),
        ));
}
