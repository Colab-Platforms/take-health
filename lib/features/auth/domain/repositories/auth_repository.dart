import 'package:classroom_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Register with email — stub for now, implement later
  Future<UserEntity> registerWithEmail(String email);

  /// Sign in with Apple — stub for now
  Future<UserEntity> signInWithApple();

  /// Sign in with Facebook — stub for now
  Future<UserEntity> signInWithFacebook();

  /// Sign in with Google — stub for now
  Future<UserEntity> signInWithGoogle();
}
