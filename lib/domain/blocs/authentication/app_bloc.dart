import 'dart:async';

import 'package:bloc/bloc.dart';

import '/domain/blocs/authentication/appuser_model.dart';
import 'auth_repository.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final AuthRepository firebaseAuthRepo;
  StreamSubscription<AuthUser?>? _userSubscription;

  AppBloc(this.firebaseAuthRepo)
      : super(firebaseAuthRepo.currentUser.isNotEmpty
            ? AppState.loadingAuthentication(firebaseAuthRepo.currentUser)
            : const AppState.unauthenticated()) {
    on<AppEvent>((event, emit) {});

    _userSubscription = firebaseAuthRepo.user.listen(
      (user) => add(AppUserChanged(user!)),
    );

    on<AppUserLoaded>((event, emit) {
      emit(AppState.authenticated(state.user));
    });

    on<AppUserChanged>((event, emit) {
      emit(event.user.isNotEmpty
          ? AppState.loadingAuthentication(event.user)
          : const AppState.unauthenticated());
    });

    on<AppLogoutRequested>((event, emit) async {
      await firebaseAuthRepo.logOut();
    });
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
