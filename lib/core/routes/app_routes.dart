import 'package:go_router/go_router.dart';
import 'package:classroom_app/features/auth/presentation/pages/splash_page.dart';
import 'package:classroom_app/features/auth/presentation/pages/create_account_page.dart';
import 'package:classroom_app/features/auth/presentation/pages/login_page.dart';
import 'package:classroom_app/features/auth/presentation/pages/reset_access_page.dart';
import 'package:classroom_app/features/auth/presentation/pages/verify_identity_page.dart';
import 'package:classroom_app/features/auth/presentation/pages/secure_account_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String createAccount = '/create-account';
  static const String login = '/login';
  static const String resetAccess = '/reset-access';
  static const String verifyIdentity = '/verify-identity';
  static const String secureAccount = '/secure-account';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.createAccount,
      name: 'createAccount',
      builder: (context, state) => const CreateAccountPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.resetAccess,
      name: 'resetAccess',
      builder: (context, state) => const ResetAccessPage(),
    ),
    GoRoute(
      path: AppRoutes.verifyIdentity,
      name: 'verifyIdentity',
      builder: (context, state) => const VerifyIdentityPage(),
    ),
    GoRoute(
      path: AppRoutes.secureAccount,
      name: 'secureAccount',
      builder: (context, state) => const SecureAccountPage(),
    ),
  ],
);
