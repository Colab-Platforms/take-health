import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:classroom_app/features/auth/domain/entities/user_entity.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<AuthFullNameChanged>(_onFullNameChanged);
    on<AuthEmailChanged>(_onEmailChanged);
    on<AuthPhoneNumberChanged>(_onPhoneNumberChanged);
    on<AuthPasswordChanged>(_onPasswordChanged);
    on<AuthCreateAccountSubmitted>(_onCreateAccountSubmitted);
    on<AuthReset>(_onReset);
  }

  void _onFullNameChanged(AuthFullNameChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(fullName: event.fullName));
  }

  void _onEmailChanged(AuthEmailChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(email: event.email));
  }

  void _onPhoneNumberChanged(AuthPhoneNumberChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(phoneNumber: event.phoneNumber));
  }

  void _onPasswordChanged(AuthPasswordChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(password: event.password));
  }

  Future<void> _onCreateAccountSubmitted(
      AuthCreateAccountSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(
        status: AuthStatus.success,
        user: UserEntity(email: state.email, authProvider: 'email'),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onReset(AuthReset event, Emitter<AuthState> emit) {
    emit(const AuthState());
  }
}
