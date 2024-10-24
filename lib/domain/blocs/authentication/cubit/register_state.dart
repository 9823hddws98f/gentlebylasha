part of 'register_cubit.dart';

enum RegisterStatus { initial, submitting, success, error }

class RegisterState {
  final String email;
  final String password;
  final RegisterStatus status;
  final String firstName;
  final String lastName;
  final String country;
  final DateTime dateOfBirth;
  final String? error;

  const RegisterState(
    this.email,
    this.password,
    this.status,
    this.firstName,
    this.lastName,
    this.country,
    this.dateOfBirth,
    this.error,
  );

  factory RegisterState.initial() {
    return RegisterState(
      '',
      '',
      RegisterStatus.initial,
      '',
      '',
      '',
      DateTime.now(),
      null,
    );
  }

  RegisterState copyWith({
    String? email,
    String? password,
    RegisterStatus? status,
    String? firstName,
    String? lastName,
    String? country,
    DateTime? dateOfBirth,
    List<String>? error,
  }) {
    return RegisterState(
      email ?? this.email,
      password ?? this.password,
      status ?? this.status,
      firstName ?? this.firstName,
      lastName ?? this.lastName,
      country ?? this.country,
      dateOfBirth ?? this.dateOfBirth,
      error != null ? error.first : this.error,
    );
  }
}
