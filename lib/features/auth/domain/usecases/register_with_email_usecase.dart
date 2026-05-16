import 'package:classroom_app/features/auth/domain/entities/user_entity.dart';
import 'package:classroom_app/features/auth/domain/repositories/auth_repository.dart';

class RegisterWithEmailUseCase {
  final AuthRepository _repository;

  const RegisterWithEmailUseCase(this._repository);

  Future<UserEntity> call(String email) async {
    return _repository.registerWithEmail(email);
  }
}
