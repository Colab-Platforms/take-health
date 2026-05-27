part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.fullName = '',
    this.email = '',
    this.phoneNumber = '',
    this.password = '',
    this.user,
    this.errorMessage,
  });

  bool get isSubmitEnabled =>
      fullName.isNotEmpty &&
          email.contains('@') &&
          phoneNumber.isNotEmpty &&
          password.length >= 6 &&
          status != AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? password,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    fullName,
    email,
    phoneNumber,
    password,
    user,
    errorMessage,
  ];
}