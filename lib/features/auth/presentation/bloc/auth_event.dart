part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthFullNameChanged extends AuthEvent {
  final String fullName;
  const AuthFullNameChanged(this.fullName);
  @override
  List<Object?> get props => [fullName];
}

class AuthEmailChanged extends AuthEvent {
  final String email;
  const AuthEmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

class AuthPhoneNumberChanged extends AuthEvent {
  final String phoneNumber;
  const AuthPhoneNumberChanged(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class AuthPasswordChanged extends AuthEvent {
  final String password;
  const AuthPasswordChanged(this.password);
  @override
  List<Object?> get props => [password];
}

class AuthCreateAccountSubmitted extends AuthEvent {
  const AuthCreateAccountSubmitted();
}

class AuthReset extends AuthEvent {
  const AuthReset();
}
