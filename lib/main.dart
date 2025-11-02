import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/app_config.dart';
import 'services/auth_bloc.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  // Garantir que os bindings do Flutter estão inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive
  await Hive.initFlutter();

  // Inicializar notificações locais
  await NotificationService.initialize();

  runApp(const PortalPacienteApp());
}

class PortalPacienteApp extends StatelessWidget {
  const PortalPacienteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = AuthBloc();
        // Dar um pequeno delay antes de verificar autenticação para garantir que splash apareça
        Future.delayed(const Duration(milliseconds: 100), () {
          bloc.add(CheckAuthStatus());
        });
        return bloc;
      },
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Color(AppConfig.currentTenant.primaryColor),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: Color(AppConfig.currentTenant.primaryColor),
            foregroundColor: Colors.white,
            elevation: AppConfig.elevation,
          ),
          cardTheme: CardThemeData(
            elevation: AppConfig.elevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: AppConfig.elevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            ),
          ),
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Mostrar splash screen durante o carregamento inicial
            if (state is AuthInitial || state is AuthLoading) {
              return const SplashScreen();
            } else if (state is AuthAuthenticated) {
              return const DashboardScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}