import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../auth_repository.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepository;

  RegisterCubit(this._authRepository) : super(RegisterState.initial());

  void emailChanged(String value) {
    emit(state.copyWith(email: value));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value));
  }

  void firstNameChanged(String value) {
    emit(state.copyWith(firstName: value));
  }

  void lastNameChanged(String value) {
    emit(state.copyWith(lastName: value));
  }

  Future<void> registerWithCredentials() async {
    if (state.status == RegisterStatus.submitting) return;

    emit(state.copyWith(status: RegisterStatus.submitting));
    try {
      await _authRepository.signUpWithEmailAndPassword(
        state.email,
        state.password,
        state.firstName,
        state.lastName,
        state.country,
        state.dateOfBirth,
      );
      emit(state.copyWith(status: RegisterStatus.success));
    } catch (e) {
      debugPrint(e.toString());
      if (isClosed) return;
      emit(state.copyWith(
        error: [e.toString()],
        status: RegisterStatus.error,
      ));
    }
  }

  void countryChanged(value) {
    emit(state.copyWith(country: value));
  }

  void dateOfBirthChanged(DateTime value) {
    emit(state.copyWith(dateOfBirth: value));
  }

  void resetError() {
    emit(state.copyWith(
      status: RegisterStatus.initial,
      error: null,
    ));
  }
}
