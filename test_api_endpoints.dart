import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiTester {
  static const String baseUrl = 'https://production.soulclinic.com.br';
  // Token deve ser fornecido via método ou argumentos
  static String? _token;

  /// Configurar token para os testes
  static void setToken(String token) {
    _token = token;
  }

  static Future<void> testAllEndpoints([String? token]) async {
    // Usar token do parâmetro ou do setter
    _token = token ?? _token;
    
    if (_token == null || _token!.isEmpty) {
      print('❌ Erro: Token não fornecido!');
      print('💡 Use: ApiTester.setToken("seu_token") ou testAllEndpoints("seu_token")');
      return;
    }
    
    print('🚀 Iniciando testes da API SoulClinic');
    print('🌐 Base URL: $baseUrl');
    print('🔑 Token: ${_token!.substring(0, _token!.length > 50 ? 50 : _token!.length)}...');
    print('=' * 80);

    // Testar conectividade básica
    await testConnectivity();

    // Testar endpoints do Portal do Paciente
    await testPortalEndpoints();

    // Testar endpoints da API Interna (JWT)
    await testInternalApiEndpoints();

    // Testar endpoints da API Externa (Token)
    await testExternalApiEndpoints();

    print('\n✅ Testes concluídos!');
  }

  static Future<void> testConnectivity() async {
    print('\n🔍 Testando conectividade...');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/portal/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      print('✅ Health Check Portal: ${response.statusCode}');
      print('📄 Response: ${response.body}');
    } catch (e) {
      print('❌ Health Check Portal falhou: $e');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      print('✅ Health Check Interna: ${response.statusCode}');
      print('📄 Response: ${response.body}');
    } catch (e) {
      print('❌ Health Check Interna falhou: $e');
    }
  }

  static Future<void> testPortalEndpoints() async {
    if (_token == null) {
      print('❌ Token não configurado para testes do Portal');
      return;
    }
    
    print('\n🏥 Testando endpoints do Portal do Paciente...');
    
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    // Testar perfil
    await testEndpoint('GET', '/api/portal/perfil', headers: headers);
    
    // Testar agendamentos
    await testEndpoint('GET', '/api/portal/agendamentos', headers: headers);
    
    // Testar carteira de vacinação
    await testEndpoint('GET', '/api/portal/carteira-vacinacao', headers: headers);
    
    // Testar documentos
    await testEndpoint('GET', '/api/portal/documentos', headers: headers);
    
    // Testar mensagens
    await testEndpoint('GET', '/api/portal/mensagens', headers: headers);
    
    // Testar notificações
    await testEndpoint('GET', '/api/portal/notificacoes', headers: headers);
    
    // Testar configurações
    await testEndpoint('GET', '/api/portal/configuracoes', headers: headers);
    
    // Testar dashboard
    await testEndpoint('GET', '/api/portal/dashboard', headers: headers);
  }

  static Future<void> testInternalApiEndpoints() async {
    if (_token == null) {
      print('❌ Token não configurado para testes da API Interna');
      return;
    }
    
    print('\n🔐 Testando endpoints da API Interna (JWT)...');
    
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    // Testar pacientes
    // NOTA: Os IDs e CPFs abaixo são apenas exemplos para testes
    // Em produção, substitua por valores reais do seu ambiente
    await testEndpoint('GET', '/api/v1/pacientes', headers: headers);
    await testEndpoint('GET', '/api/v1/pacientes?id=1', headers: headers); // ID de exemplo
    await testEndpoint('GET', '/api/v1/pacientes?cpf=065.971.289-07', headers: headers); // CPF de exemplo
    
    // Testar agendas
    // NOTA: Os IDs abaixo são apenas exemplos para testes
    await testEndpoint('GET', '/api/v1/agendas', headers: headers);
    await testEndpoint('GET', '/api/v1/agendas?profissional_id=1', headers: headers); // ID de exemplo
    await testEndpoint('GET', '/api/v1/agendas?paciente_id=1', headers: headers); // ID de exemplo
    
    // Testar unidades de atendimento
    await testEndpoint('GET', '/api/v1/unidades-atendimento', headers: headers);
    
    // Testar convênios
    await testEndpoint('GET', '/api/v1/convenios', headers: headers);
    
    // Testar salas
    await testEndpoint('GET', '/api/v1/salas', headers: headers);
    
    // Testar procedimentos
    await testEndpoint('GET', '/api/v1/procedimentos', headers: headers);
    
    // Testar tipos de acompanhante
    await testEndpoint('GET', '/api/v1/tipos-acompanhante', headers: headers);
  }

  static Future<void> testExternalApiEndpoints() async {
    if (_token == null) {
      print('❌ Token não configurado para testes da API Externa');
      return;
    }
    
    print('\n🌐 Testando endpoints da API Externa (Token)...');
    
    final headers = {
      'Content-Type': 'application/json',
      'X-API-Token': _token!, // Usando o mesmo token como API token
    };

    // Testar pacientes
    // NOTA: Os IDs e CPFs abaixo são apenas exemplos para testes
    // Em produção, substitua por valores reais do seu ambiente
    await testEndpoint('GET', '/external/v1/pacientes', headers: headers);
    await testEndpoint('GET', '/external/v1/pacientes?id=1', headers: headers); // ID de exemplo
    await testEndpoint('GET', '/external/v1/pacientes?cpf=065.971.289-07', headers: headers); // CPF de exemplo
    
    // Testar agendas
    // NOTA: Os IDs abaixo são apenas exemplos para testes
    await testEndpoint('GET', '/external/v1/agendas', headers: headers);
    await testEndpoint('GET', '/external/v1/agendas?profissional_id=1', headers: headers); // ID de exemplo
    await testEndpoint('GET', '/external/v1/agendas?paciente_id=1', headers: headers); // ID de exemplo
    
    // Testar unidades de atendimento
    await testEndpoint('GET', '/external/v1/unidades-atendimento', headers: headers);
    
    // Testar convênios
    await testEndpoint('GET', '/external/v1/convenios', headers: headers);
    
    // Testar salas
    await testEndpoint('GET', '/external/v1/salas', headers: headers);
    
    // Testar procedimentos
    await testEndpoint('GET', '/external/v1/procedimentos', headers: headers);
    
    // Testar tipos de acompanhante
    await testEndpoint('GET', '/external/v1/tipos-acompanhante', headers: headers);
  }

  static Future<void> testEndpoint(String method, String path, {Map<String, String>? headers, dynamic body}) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers).timeout(Duration(seconds: 10));
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: body).timeout(Duration(seconds: 10));
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: body).timeout(Duration(seconds: 10));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers).timeout(Duration(seconds: 10));
          break;
        default:
          print('❌ Método HTTP não suportado: $method');
          return;
      }
      
      final status = response.statusCode;
      final statusIcon = status >= 200 && status < 300 ? '✅' : '❌';
      
      print('$statusIcon $method $path - Status: $status');
      
      if (response.body.isNotEmpty) {
        try {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse is Map && jsonResponse.containsKey('success')) {
            print('   📊 Success: ${jsonResponse['success']}');
            print('   💬 Message: ${jsonResponse['message']}');
            if (jsonResponse.containsKey('data')) {
              final data = jsonResponse['data'];
              if (data is List) {
                print('   📋 Data: Lista com ${data.length} itens');
              } else if (data is Map) {
                print('   📋 Data: Objeto com ${data.keys.length} campos');
              } else {
                print('   📋 Data: $data');
              }
            }
          } else {
            print('   📄 Response: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
          }
        } catch (e) {
          print('   📄 Response: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
        }
      }
      
    } catch (e) {
      print('❌ $method $path - Erro: $e');
    }
  }
}

/// Exemplo de uso:
/// 
/// ```dart
/// // Opção 1: Passar token como parâmetro
/// await ApiTester.testAllEndpoints('seu_token_jwt_aqui');
/// 
/// // Opção 2: Configurar token antes
/// ApiTester.setToken('seu_token_jwt_aqui');
/// await ApiTester.testAllEndpoints();
/// ```
void main(List<String> args) async {
  // Obter token dos argumentos ou solicitar
  if (args.isNotEmpty) {
    await ApiTester.testAllEndpoints(args[0]);
  } else {
    print('⚠️  Token não fornecido como argumento!');
    print('💡 Uso: dart test_api_endpoints.dart <seu_token_jwt>');
    print('💡 Ou use: ApiTester.setToken("token") antes de chamar testAllEndpoints()');
    print('');
    print('🔐 Por favor, forneça o token JWT como argumento:');
    print('   dart test_api_endpoints.dart <seu_token_jwt>');
  }
}
