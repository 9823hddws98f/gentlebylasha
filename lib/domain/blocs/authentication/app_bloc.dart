import 'dart:async';

import 'package:bloc/bloc.dart';

import '/domain/blocs/authentication/appuser_model.dart';
import '/domain/blocs/user/user_bloc.dart';
import '/utils/get.dart';
import 'auth_repository.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final AuthRepository _auth;
  StreamSubscription<AuthUser?>? _userSubscription;

  late final _userBloc = Get.the<UserBloc>();

  AppBloc(this._auth) : super(AppState(user: _auth.currentUser)) {
    on<AppEvent>((event, emit) async {
      if (event is AppUserChanged) {
        emit(event.user.isNotEmpty
            ? AppState(user: event.user)
            : const AppState(user: null));

        // Firebase auth was successful, now we need to login with userBloc
        _userBloc.add(UserLoaded(event.user.toAppUser()));
      } else if (event is AppLogoutRequested) {
        await _auth.logOut();
        emit(const AppState(user: null));
      }
    });

    _userSubscription = _auth.user.listen(
      (user) => add(AppUserChanged(user!)),
    );
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
