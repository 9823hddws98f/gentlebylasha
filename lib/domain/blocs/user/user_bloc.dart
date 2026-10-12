import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/app_init.dart';
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
        await _userSubscription?.cancel();
        _userSubscription = null;
        final authUser = FirebaseAuth.instance.currentUser;
        if (event.user.id.isEmpty || authUser == null) {
          emit(UserInitial());
          return;
        }

        final user = await _usersService.getOrCreate(authUser);
        emit(UserInitial().copyWith(user: user));
        await AppInit.initUserBasedServices();
        _userSubscription = _usersService.watchById(event.user.id).listen(
          (user) {
            if (user != state.user) add(UserUpdated(user));
          },
          // The profile disappears when the account is deleted; nothing to show then.
          onError: (_) {},
        );
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
