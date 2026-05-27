import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:classroom_app/features/auth/domain/entities/user_entity.dart';
import 'package:classroom_app/features/auth/domain/usecases/send_registration_otp_use_case.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendRegistrationOtpUseCase _sendRegistrationOtpUseCase;

  AuthBloc({
    required SendRegistrationOtpUseCase sendRegistrationOtpUseCase,
  }) : _sendRegistrationOtpUseCase = sendRegistrationOtpUseCase,
        super(const AuthState()) {
    on<AuthFullNameChanged>(_onFullNameChanged);
    on<AuthEmailChanged>(_onEmailChanged);
    on<AuthPhoneNumberChanged>(_onPhoneNumberChanged);
    on<AuthPasswordChanged>(_onPasswordChanged);
    on<AuthSendRegistrationOtp>(_onSendRegistrationOtp);
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

  Future<void> _onSendRegistrationOtp(
      AuthSendRegistrationOtp event,
      Emitter<AuthState> emit,
      ) async {
    // Validate form before sending
    if (!state.isSubmitEnabled) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Please fill all fields correctly',
      ));
      return;
    }

    // Additional email validation
    if (!_isValidEmail(state.email)) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Please enter a valid email address',
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await _sendRegistrationOtpUseCase(
        state.fullName,
        state.email,
      );

      if (response['success'] == true) {
        emit(state.copyWith(
          status: AuthStatus.success,
          user: UserEntity(
            email: state.email,
            name: state.fullName,
            authProvider: 'email',
          ),
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: response['message'] ?? 'Failed to send verification code',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  void _onReset(AuthReset event, Emitter<AuthState> emit) {
    emit(const AuthState());
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}