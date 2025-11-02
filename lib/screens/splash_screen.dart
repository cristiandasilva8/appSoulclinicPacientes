import 'package:flutter/material.dart';
import '../config/app_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    
    // Animação para os pontos aparecendo
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // 600ms por ponto (total 1.8s para 3 pontos)
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4; // 0, 1, 2, 3 (sem pontos até 3 pontos)
        });
        _animationController.reset();
        _animationController.forward();
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo da SoulClinic
            _buildLogo(),
            
            const SizedBox(height: 40),
            
            // Mensagem para o paciente
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Bem-vindo ao Portal do Paciente\nSoulClinic',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(AppConfig.currentTenant.primaryColor),
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 50),
            
            // Texto "Carregando" com pontos animados
            Text(
              'Carregando${'.' * _dotCount}',
              style: TextStyle(
                fontSize: 16,
                color: Color(AppConfig.currentTenant.primaryColor).withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final logoUrl = AppConfig.currentTenant.logoUrl;
    
    if (logoUrl != null) {
      return Image.asset(
        logoUrl,
        height: 120,
        width: 120,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultIcon();
        },
      );
    }
    
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Color(AppConfig.currentTenant.primaryColor),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.local_hospital,
        size: 60,
        color: Colors.white,
      ),
    );
  }
}

