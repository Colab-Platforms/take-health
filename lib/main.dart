import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:classroom_app/core/theme/app_theme.dart';
import 'package:classroom_app/core/utils/service_locator.dart';
import 'package:classroom_app/features/auth/presentation/bloc/auth_bloc.dart';

import 'core/routes/app_routes.dart';
import 'features/home/domain/entities/user_profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  setupServiceLocator();

  // Load saved profile data before app starts
  await UserProfileProvider.instance.loadFromPrefs();

  runApp(const ClassroomApp());
}

class ClassroomApp extends StatelessWidget {
  const ClassroomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: UserProfileProvider.instance,
      child: BlocProvider<AuthBloc>(
        create: (_) => sl<AuthBloc>(),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}