import 'package:classroom_app/features/auth/data/models/user_model.dart';

/// Remote data source — all methods are stubs.
/// Replace with actual API calls when the backend is ready.
abstract class AuthRemoteDataSource {
  Future<UserModel> registerWithEmail(String email);
  Future<UserModel> signInWithApple();
  Future<UserModel> signInWithFacebook();
  Future<UserModel> signInWithGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // TODO: inject your http client / Dio here
  // final Dio _dio;
  // AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<UserModel> registerWithEmail(String email) async {
    // TODO: POST /auth/register { email }
    throw UnimplementedError('registerWithEmail not implemented yet');
  }

  @override
  Future<UserModel> signInWithApple() async {
    // TODO: Apple Sign-In flow
    throw UnimplementedError('signInWithApple not implemented yet');
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    // TODO: Facebook Sign-In flow
    throw UnimplementedError('signInWithFacebook not implemented yet');
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    // TODO: Google Sign-In flow
    throw UnimplementedError('signInWithGoogle not implemented yet');
  }
}
