class AppConfig {
  // Configurações de Multitenancy
  static const Map<String, TenantConfig> tenants = {
    'soulclinic': TenantConfig(
      name: 'SoulClinic',
      baseUrl: 'https://seu-dominio.com/api/portal',
      primaryColor: 0xFF2196F3,
      logoUrl: 'assets/images/soulclinic_logo.png',
    ),
    'clinicaexemplo': TenantConfig(
      name: 'Clínica Exemplo',
      baseUrl: 'https://exemplo.com/api/portal',
      primaryColor: 0xFF4CAF50,
      logoUrl: 'assets/images/exemplo_logo.png',
    ),
  };

  // Configurações gerais
  static const String appName = 'Portal do Paciente';
  static const String appVersion = '1.0.0';
  static const int tokenExpirationMinutes = 60;
  static const int refreshTokenExpirationDays = 30;
  
  // Configurações de API
  static const int requestTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  
  // Configurações de UI
  static const double defaultPadding = 16.0;
  static const double borderRadius = 8.0;
  static const double elevation = 2.0;
}

class TenantConfig {
  final String name;
  final String baseUrl;
  final int primaryColor;
  final String logoUrl;

  const TenantConfig({
    required this.name,
    required this.baseUrl,
    required this.primaryColor,
    required this.logoUrl,
  });
}
