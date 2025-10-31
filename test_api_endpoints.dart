import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiTester {
  static const String baseUrl = 'http://localhost:8080';
  static const String token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwYWNpZW50ZV9pZCI6IjEiLCJjcGYiOiIwNjUuOTcxLjI4OS0wNyIsIm5vbWUiOiJQYWNpZW50ZSB0ZXN0ZSIsImVtYWlsIjoibHVhbmFkdXRyYWRjQGdtYWlsLmNvbSIsInRlbmFudF9pZCI6IjY1IiwiZGF0YWJhc2VfZ3JvdXAiOiJncm91cF9jbGluaWNhX2R1dHJhXzY1IiwiaXNzIjoiU291bENsaW5pYyBBUEkiLCJhdWQiOiJTb3VsQ2xpbmljIFVzZXJzIiwiaWF0IjoxNzYxNzgxNjQ3LCJleHAiOjE3NjE3ODUyNDd9.9IIHTJmK2oMBD4vpJwUQ_iMKc3Uzv885sWfeKXDnf-U';

  static Future<void> testAllEndpoints() async {
    print('🚀 Iniciando testes da API SoulClinic');
    print('🌐 Base URL: $baseUrl');
    print('🔑 Token: ${token.substring(0, 50)}...');
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
    print('\n🏥 Testando endpoints do Portal do Paciente...');
    
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
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
    print('\n🔐 Testando endpoints da API Interna (JWT)...');
    
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Testar pacientes
    await testEndpoint('GET', '/api/v1/pacientes', headers: headers);
    await testEndpoint('GET', '/api/v1/pacientes?id=1', headers: headers);
    await testEndpoint('GET', '/api/v1/pacientes?cpf=065.971.289-07', headers: headers);
    
    // Testar agendas
    await testEndpoint('GET', '/api/v1/agendas', headers: headers);
    await testEndpoint('GET', '/api/v1/agendas?profissional_id=1', headers: headers);
    await testEndpoint('GET', '/api/v1/agendas?paciente_id=1', headers: headers);
    
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
    print('\n🌐 Testando endpoints da API Externa (Token)...');
    
    final headers = {
      'Content-Type': 'application/json',
      'X-API-Token': token, // Usando o mesmo token como API token
    };

    // Testar pacientes
    await testEndpoint('GET', '/external/v1/pacientes', headers: headers);
    await testEndpoint('GET', '/external/v1/pacientes?id=1', headers: headers);
    await testEndpoint('GET', '/external/v1/pacientes?cpf=065.971.289-07', headers: headers);
    
    // Testar agendas
    await testEndpoint('GET', '/external/v1/agendas', headers: headers);
    await testEndpoint('GET', '/external/v1/agendas?profissional_id=1', headers: headers);
    await testEndpoint('GET', '/external/v1/agendas?paciente_id=1', headers: headers);
    
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

void main() async {
  await ApiTester.testAllEndpoints();
}
