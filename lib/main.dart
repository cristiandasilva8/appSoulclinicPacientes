import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/app_config.dart';
import 'services/auth_bloc.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const PortalPacienteApp());
}

class PortalPacienteApp extends StatelessWidget {
  const PortalPacienteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc()..add(CheckAuthStatus()),
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
            if (state is AuthLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
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