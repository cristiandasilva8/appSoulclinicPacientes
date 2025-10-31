import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'api_service.dart';

class DebugService {
  final ApiService _apiService = ApiService();

  /// Testa se o token está sendo enviado corretamente
  Future<void> testarTokenEnviado() async {
    try {
      final token = await _apiService.getToken();
      
      if (token == null) {
        log('❌ Token não encontrado no SharedPreferences');
        return;
      }

      log('✅ Token encontrado: ${token.substring(0, 20)}...');
      
      // Testar requisição com token
      final response = await _apiService.get('/perfil');
      
      if (response.success) {
        log('✅ Requisição autenticada funcionou!');
        log('📊 Resposta: ${jsonEncode(response.data)}');
      } else {
        log('❌ Erro na requisição: ${response.message}');
      }
      
    } catch (e) {
      log('❌ Erro ao testar token: $e');
    }
  }

  /// Testa requisição PUT para atualizar paciente
  Future<void> testarAtualizacaoPaciente(int pacienteId) async {
    try {
      final token = await _apiService.getToken();
      
      if (token == null) {
        log('❌ Token não encontrado');
        return;
      }

      log('🔑 Token disponível: ${token.substring(0, 20)}...');
      
      // Dados de teste para atualização
      final dadosAtualizacao = {
        'nome': 'Teste Atualização Flutter',
        'email': 'teste.flutter@email.com',
        'telefone': '(11) 99999-9999',
      };

      log('📤 Enviando requisição PUT para /api/v1/pacientes/$pacienteId');
      log('📤 Dados: ${jsonEncode(dadosAtualizacao)}');
      
      // Fazer requisição PUT
      final response = await _apiService.put(
        '/api/v1/pacientes/$pacienteId',
        data: dadosAtualizacao,
      );
      
      if (response.success) {
        log('✅ Paciente atualizado com sucesso!');
        log('📊 Resposta: ${jsonEncode(response.data)}');
      } else {
        log('❌ Erro ao atualizar paciente: ${response.message}');
        if (response.errors != null) {
          log('📋 Erros de validação: ${jsonEncode(response.errors)}');
        }
      }
      
    } catch (e) {
      log('❌ Erro na requisição: $e');
    }
  }

  /// Verifica se o interceptor está funcionando
  Future<void> verificarInterceptor() async {
    try {
      // Criar um Dio separado para testar o interceptor
      final dio = Dio();
      
      // Adicionar interceptor de debug
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            log('📤 Requisição sendo enviada:');
            log('   URL: ${options.uri}');
            log('   Method: ${options.method}');
            log('   Headers: ${jsonEncode(options.headers)}');
            handler.next(options);
          },
          onResponse: (response, handler) {
            log('📥 Resposta recebida:');
            log('   Status: ${response.statusCode}');
            log('   Headers: ${jsonEncode(response.headers.map)}');
            handler.next(response);
          },
          onError: (error, handler) {
            log('❌ Erro na requisição:');
            log('   Status: ${error.response?.statusCode}');
            log('   Message: ${error.message}');
            handler.next(error);
          },
        ),
      );

      // Testar requisição
      final response = await dio.get('http://localhost:8080/api/portal/clientes');
      log('✅ Requisição de teste funcionou: ${response.statusCode}');
      
    } catch (e) {
      log('❌ Erro no teste do interceptor: $e');
    }
  }
}
