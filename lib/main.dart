import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_theme.dart';
import 'core/utils/dependency_injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/feed/presentation/pages/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF050505),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Setup dependency injection
  await setupDependencyInjection();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>()..add(const CheckAuthStatus()),
      child: MaterialApp(
        title: 'Prism',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Show loading screen while checking auth status
            if (state.status == AuthStatus.initial) {
              return const Scaffold(
                backgroundColor: Color(0xFF050505),
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF00F2EA)),
                ),
              );
            }

            // If authenticated, show main scaffold with bottom navigation
            if (state.status == AuthStatus.authenticated) {
              return const MainScaffold();
            }

            // Otherwise show login page
            return const LoginPage();
          },
        ),
      ),
    );
  }
}
