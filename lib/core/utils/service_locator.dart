import 'package:get_it/get_it.dart';
import 'package:classroom_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:classroom_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:classroom_app/features/auth/domain/usecases/register_with_email_usecase.dart';
import 'package:classroom_app/features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/auth/data/datasource/auth_remote_data_source.dart';
import '../../features/auth/domain/usecases/social_sig_in_usecase.dart';

final GetIt sl = GetIt.instance;

void setupServiceLocator() {
  // ── Data sources ──────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(),
  );

  // ── Repositories ──────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(sl()),
  );

  // ── Use cases ─────────────────────────────────────────────────
  sl.registerLazySingleton(() => RegisterWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithAppleUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithFacebookUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));

  // ── BLoC ──────────────────────────────────────────────────────
  sl.registerFactory(
        () => AuthBloc(

    ),
  );
}
