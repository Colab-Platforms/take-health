import 'package:classroom_app/features/auth/domain/entities/user_entity.dart';
import 'package:classroom_app/features/auth/domain/repositories/auth_repository.dart';

import '../datasource/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserEntity> registerWithEmail(String email) async {
    // TODO: add error handling / mapping when API is integrated
    final model = await _remoteDataSource.registerWithEmail(email);
    return model;
  }

  @override
  Future<UserEntity> signInWithApple() async {
    final model = await _remoteDataSource.signInWithApple();
    return model;
  }

  @override
  Future<UserEntity> signInWithFacebook() async {
    final model = await _remoteDataSource.signInWithFacebook();
    return model;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final model = await _remoteDataSource.signInWithGoogle();
    return model;
  }
}
