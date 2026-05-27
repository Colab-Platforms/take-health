import 'package:classroom_app/features/auth/domain/repositories/auth_repository.dart';

class SendRegistrationOtpUseCase {
  final AuthRepository _repository;

  const SendRegistrationOtpUseCase(this._repository);

  Future<Map<String, dynamic>> call(String name, String email) async {
    return _repository.sendRegistrationOtp(name, email);
  }
}