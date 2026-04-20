import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'config/api_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/services/supabase_auth_service.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase antes de arrancar la app
  await Supabase.initialize(
    url: ApiConfig.supabaseUrl,
    anonKey: ApiConfig.supabaseAnonKey,
  );

  runApp(const StudyBytesApp());
}

// Acceso global al cliente de Supabase
final supabase = Supabase.instance.client;

class StudyBytesApp extends StatelessWidget {
  const StudyBytesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => SupabaseAuthService(),
      child: BlocProvider(
        create: (context) => AuthBloc(context.read<SupabaseAuthService>())

          ..add(AuthCheckRequested()),
        child: MaterialApp(
          title: 'StudyBytes',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const _AppRouter(),
        ),
      ),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school_rounded, size: 56, color: AppTheme.primaryBlue),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
        }
        if (state is AuthAuthenticated) return const MainPage();
        return const LoginScreen();
      },
    );
  }
}
