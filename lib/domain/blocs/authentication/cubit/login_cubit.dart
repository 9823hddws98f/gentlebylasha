import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '/domain/blocs/authentication/auth_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit(this._authRepository) : super(LoginState.initial());

  void emailChanged(String value) {
    emit(state.copyWith(email: value));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value));
  }

  Future<void> logInWithCredentials(bool rememberMe) async {
    if (state.status == LoginStatus.submitting) return;

    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      await _authRepository.logInWithEmailAndPassword(
          state.email, state.password, rememberMe);
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(status: LoginStatus.error));
    }
  }

  void resetStatus() {
    emit(state.copyWith(status: LoginStatus.initial));
  }
}
