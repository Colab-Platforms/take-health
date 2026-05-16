import 'package:classroom_app/features/auth/domain/entities/user_entity.dart';
import 'package:classroom_app/features/auth/domain/repositories/auth_repository.dart';

class SignInWithAppleUseCase {
  final AuthRepository _repository;
  const SignInWithAppleUseCase(this._repository);
  Future<UserEntity> call() => _repository.signInWithApple();
}

class SignInWithFacebookUseCase {
  final AuthRepository _repository;
  const SignInWithFacebookUseCase(this._repository);
  Future<UserEntity> call() => _repository.signInWithFacebook();
}

class SignInWithGoogleUseCase {
  final AuthRepository _repository;
  const SignInWithGoogleUseCase(this._repository);
  Future<UserEntity> call() => _repository.signInWithGoogle();
}
