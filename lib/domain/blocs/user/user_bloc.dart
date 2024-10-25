import 'dart:async';

import 'package:bloc/bloc.dart';

import '/domain/blocs/authentication/app_bloc.dart';
import '/domain/services/user_service.dart';
import 'app_user.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UsersService _usersService;
  StreamSubscription<AppUser>? _userSubscription;

  UserBloc(this._usersService) : super(UserInitial()) {
    on<UserEvent>((event, emit) async {
      if (event is UserLoaded) {
        final user = await _usersService.getById(event.user.id);
        emit(UserInitial().copyWith(user: user));
        event.appbloc.add(const AppUserLoaded());
        _userSubscription = _usersService.watchById(event.user.id).listen((user) {
          add(UserUpdated(user));
        });
      }

      if (event is UserUpdated) {
        emit(UserInitial().copyWith(user: event.user));
      }

      if (event is UserModified) {
        await _usersService.update(event.user);
        emit(UserInitial().copyWith(user: event.user));
      }
    });
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}