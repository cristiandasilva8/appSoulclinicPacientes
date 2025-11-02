import 'package:flutter/foundation.dart' show kDebugMode;

class AppConfig {
  // Configurações de ambiente
  // Forçar produção: defina FORCE_PRODUCTION=true nas variáveis de ambiente
  // Exemplo: flutter run --dart-define=FORCE_PRODUCTION=true
  static const bool _forceProduction = bool.fromEnvironment('FORCE_PRODUCTION', defaultValue: false);
  
  // Usa kDebugMode do Flutter que é mais confiável que bool.fromEnvironment
  // Mas permite forçar produção mesmo em debug para testes
  static bool get isDebug => _forceProduction ? false : kDebugMode;
  
  // URLs baseadas no ambiente
  static const String _baseUrlProducao = 'https://production.soulclinic.com.br/api/portal';
  static const String _baseUrlHomologacao = 'http://127.0.0.1:8080/api/portal';
  
  // Configurações de Multitenancy
  // Usa homologação em debug e produção em release
  static Map<String, TenantConfig> get tenants => {
    'soulclinic': TenantConfig(
      name: 'SoulClinic',
      baseUrl: isDebug ? _baseUrlHomologacao : _baseUrlProducao,
      primaryColor: 0xFF2196F3,
      logoUrl: 'assets/images/soulclinic_logo.png',
      crmDomain: 'soulclinic.com',
    ),
    'clinicaexemplo': TenantConfig(
      name: 'Clínica Exemplo',
      baseUrl: isDebug ? _baseUrlHomologacao : 'https://production.exemplo.com.br/api/portal',
      primaryColor: 0xFF4CAF50,
      logoUrl: 'assets/images/exemplo_logo.png',
      crmDomain: 'exemplo.com',
    ),
  };

  // Configuração da clínica atual (detectada automaticamente)
  static String _currentTenant = 'soulclinic'; // Default
  
  // Detectar clínica baseada no ambiente
  static String detectTenantFromCrm() {
    // Em produção, isso seria baseado no domínio atual ou configuração do servidor
    // Por enquanto, vamos usar uma configuração fixa ou detectar via ambiente
    return _currentTenant;
  }
  
  // Configurar clínica atual
  static void setCurrentTenant(String tenant) {
    _currentTenant = tenant;
  }
  
  // Obter configuração da clínica atual
  static TenantConfig get currentTenant {
    return tenants[_currentTenant] ?? tenants['soulclinic']!;
  }

  // Configurações gerais
  static const String appName = 'Portal do Paciente';
  static const String appVersion = '1.0.0';
  static const int tokenExpirationMinutes = 60;
  static const int refreshTokenExpirationDays = 30;
  
  // Informações de debug
  static String get environmentInfo {
    return isDebug ? 'HOMOLOGAÇÃO' : 'PRODUÇÃO';
  }
  
  static String get currentBaseUrl {
    return currentTenant.baseUrl;
  }
  
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
  final String? logoUrl; // Opcional - se não existir, usa ícone padrão
  final String crmDomain;

  const TenantConfig({
    required this.name,
    required this.baseUrl,
    required this.primaryColor,
    this.logoUrl, // Não é mais obrigatório
    required this.crmDomain,
  });
}
