import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/api_response.dart';

class PortalTestService {
  static const String baseUrl = 'https://production.soulclinic.com.br/api/portal';

  // Testar todos os endpoints do Portal do Paciente
  static Future<Map<String, dynamic>> testAllPortalEndpoints(String token) async {
    final results = <String, dynamic>{};
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    print('🧪 Testando endpoints do Portal do Paciente...');
    print('🔑 Token: ${token.substring(0, 50)}...');
    print('=' * 60);

    // Lista de endpoints para testar
    final endpoints = [
      {'name': 'Perfil', 'path': '/perfil'},
      {'name': 'Agendamentos', 'path': '/agendamentos'},
      {'name': 'Carteira Vacinação', 'path': '/carteira-vacinacao'},
      {'name': 'Documentos', 'path': '/documentos'},
      {'name': 'Mensagens', 'path': '/mensagens'},
      {'name': 'Notificações', 'path': '/notificacoes'},
      {'name': 'Configurações', 'path': '/configuracoes'},
      {'name': 'Dashboard', 'path': '/dashboard'},
    ];

    for (final endpoint in endpoints) {
      final result = await testEndpoint(
        endpoint['name']!,
        endpoint['path']!,
        headers: headers,
      );
      results[endpoint['name']!] = result;
    }

    return results;
  }

  static Future<Map<String, dynamic>> testEndpoint(
    String name,
    String path, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await http.get(uri, headers: headers).timeout(
        Duration(seconds: 10),
      );

      final status = response.statusCode;
      final isSuccess = status >= 200 && status < 300;
      
      print('${isSuccess ? '✅' : '❌'} $name - Status: $status');

      Map<String, dynamic> result = {
        'success': isSuccess,
        'status': status,
        'path': path,
      };

      if (response.body.isNotEmpty) {
        try {
          final jsonResponse = json.decode(response.body);
          result['response'] = jsonResponse;
          
          if (jsonResponse is Map) {
            result['api_success'] = jsonResponse['success'] ?? false;
            result['message'] = jsonResponse['message'];
            
            if (jsonResponse.containsKey('data')) {
              final data = jsonResponse['data'];
              if (data is List) {
                result['data_count'] = data.length;
                result['data_type'] = 'List';
              } else if (data is Map) {
                result['data_count'] = data.keys.length;
                result['data_type'] = 'Object';
                result['data_keys'] = data.keys.toList();
              } else {
                result['data_value'] = data;
                result['data_type'] = data.runtimeType.toString();
              }
            }
          }
        } catch (e) {
          result['raw_response'] = response.body;
          result['parse_error'] = e.toString();
        }
      }

      return result;
    } catch (e) {
      print('❌ $name - Erro: $e');
      return {
        'success': false,
        'error': e.toString(),
        'path': path,
      };
    }
  }

  // Testar login com CPF e senha
  static Future<Map<String, dynamic>> testLogin({
    required String cpf,
    required String senha,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/login');
      final body = json.encode({
        'cpf': cpf,
        'senha': senha,
      });

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(Duration(seconds: 10));

      final status = response.statusCode;
      final isSuccess = status >= 200 && status < 300;
      
      print('${isSuccess ? '✅' : '❌'} Login - Status: $status');

      Map<String, dynamic> result = {
        'success': isSuccess,
        'status': status,
      };

      if (response.body.isNotEmpty) {
        try {
          final jsonResponse = json.decode(response.body);
          result['response'] = jsonResponse;
          
          if (jsonResponse is Map) {
            result['api_success'] = jsonResponse['success'] ?? false;
            result['message'] = jsonResponse['message'];
            
            if (jsonResponse.containsKey('data')) {
              final data = jsonResponse['data'];
              if (data is Map && data.containsKey('token')) {
                result['token'] = data['token'];
                result['has_token'] = true;
              }
            }
          }
        } catch (e) {
          result['raw_response'] = response.body;
          result['parse_error'] = e.toString();
        }
      }

      return result;
    } catch (e) {
      print('❌ Login - Erro: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Gerar relatório de testes
  static void generateReport(Map<String, dynamic> results) {
    print('\n📊 RELATÓRIO DE TESTES DO PORTAL DO PACIENTE');
    print('=' * 60);
    
    int totalTests = results.length;
    int successTests = 0;
    int failedTests = 0;
    
    results.forEach((name, result) {
      if (result['success'] == true) {
        successTests++;
        print('✅ $name: OK');
        if (result['data_count'] != null) {
          print('   📊 Dados: ${result['data_type']} com ${result['data_count']} itens');
        }
        if (result['message'] != null && result['message'].isNotEmpty) {
          print('   💬 Mensagem: ${result['message']}');
        }
      } else {
        failedTests++;
        print('❌ $name: FALHOU');
        if (result['error'] != null) {
          print('   🚨 Erro: ${result['error']}');
        }
        if (result['message'] != null && result['message'].isNotEmpty) {
          print('   💬 Mensagem: ${result['message']}');
        }
      }
    });
    
    print('\n📈 RESUMO:');
    print('   Total: $totalTests');
    print('   ✅ Sucessos: $successTests');
    print('   ❌ Falhas: $failedTests');
    print('   📊 Taxa de sucesso: ${((successTests / totalTests) * 100).toStringAsFixed(1)}%');
  }
}
