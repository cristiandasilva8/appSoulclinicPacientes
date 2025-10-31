import 'dart:convert';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'cliente_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final ClienteService _clienteService = ClienteService();

  // Login
  Future<ApiResponse<LoginResponse>> login({
    required String cpf,
    required String senha,
    required String dbGroup,
  }) async {
    print('🔍 Iniciando processo de login...');
    print('📝 CPF: $cpf');
    print('📝 DB Group: $dbGroup');
    
    // Configurar tenant antes da requisição
    await _apiService.setTenant(dbGroup);
    
    // Fazer login real na API
    print('🌐 Fazendo requisição de login para a API...');
    print('📋 Endpoint: /auth/login');
    print('📋 Dados: {cpf: $cpf, db_group: $dbGroup}');
    
    final response = await _apiService.post<LoginResponse>(
      '/auth/login',
      data: {
        'cpf': cpf,
        'senha': senha,
        'db_group': dbGroup,
      },
      fromJson: (data) {
        print('🔄 Processando LoginResponse.fromJson com data: $data');
        try {
          final loginResponse = LoginResponse.fromJson(data);
          print('✅ LoginResponse criado com sucesso');
          return loginResponse;
        } catch (e, stackTrace) {
          print('❌ Erro ao criar LoginResponse: $e');
          print('❌ Stack trace: $stackTrace');
          rethrow;
        }
      },
    );
    
    print('📡 Resposta do login: success=${response.success}, message=${response.message}');
    print('📡 Response.data é null? ${response.data == null}');
    
    // Se login foi bem-sucedido, salvar tokens
    if (response.success && response.data != null) {
      print('✅ Login bem-sucedido!');
      print('💾 Salvando tokens...');
      await _apiService.saveToken(response.data!.token);
      await _apiService.saveRefreshToken(response.data!.refreshToken);
      print('✅ Tokens salvos com sucesso');
      print('👤 Usuário: ${response.data!.user.nome}');
    } else {
      print('❌ Login falhou: ${response.message}');
    }
    
    return response;
  }

  // Logout
  Future<ApiResponse<void>> logout() async {
    final response = await _apiService.post<void>('/auth/logout');
    
    // Limpar tokens independente da resposta
    await _apiService.clearTokens();
    
    return response;
  }

  // Verificar CPF
  Future<ApiResponse<VerificarCpfResponse>> verificarCpf({
    required String cpf,
    required String dbGroup,
  }) async {
    // Configurar tenant antes da requisição
    await _apiService.setTenant(dbGroup);

    return await _apiService.post<VerificarCpfResponse>(
      '/auth/verificar-cpf',
      data: {
        'cpf': cpf,
        'db_group': dbGroup,
      },
      fromJson: (data) => VerificarCpfResponse.fromJson(data),
    );
  }

  // Refresh Token
  Future<ApiResponse<RefreshTokenResponse>> refreshToken() async {
    final refreshToken = await _apiService.getRefreshToken();
    if (refreshToken == null) {
      return ApiResponse(
        success: false,
        message: 'Refresh token não encontrado',
      );
    }

    final response = await _apiService.post<RefreshTokenResponse>(
      '/auth/refresh',
      data: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
      fromJson: (data) => RefreshTokenResponse.fromJson(data),
    );

    // Salvar novos tokens se renovação foi bem-sucedida
    if (response.success && response.data != null) {
      await _apiService.saveToken(response.data!.token);
      await _apiService.saveRefreshToken(response.data!.refreshToken);
    }

    return response;
  }

  // Verificar se está autenticado
  Future<bool> isAuthenticated() async {
    return await _apiService.isAuthenticated();
  }

  // Obter usuário atual (do token)
  Future<User?> getCurrentUser() async {
    try {
      final token = await _apiService.getToken();
      if (token == null || token.isEmpty) {
        print('❌ Token não encontrado ou vazio');
        return null;
      }

      print('🔍 Decodificando JWT token...');
      
      // Decodificar JWT para obter dados do usuário
      // Nota: Em produção, você deve validar o token no servidor
      // Aqui estamos apenas extraindo os dados para uso local
      final parts = token.split('.');
      if (parts.length != 3) {
        print('❌ Token JWT inválido - não tem 3 partes');
        return null;
      }

      final payload = parts[1];
      print('🔍 Payload JWT: ${payload.substring(0, 20)}...');
      
      // Adicionar padding se necessário
      final normalized = base64Url.normalize(payload);
      final decoded = base64Url.decode(normalized);
      final resp = utf8.decode(decoded);
      
      print('🔍 Payload decodificado: $resp');
      
      final payloadMap = json.decode(resp);
      print('🔍 Payload como Map: $payloadMap');

      // Verificar se tem dados do usuário
      if (payloadMap['user'] != null) {
        return User.fromJson(payloadMap['user']);
      } else if (payloadMap['id'] != null) {
        // Se os dados estão diretamente no payload
        return User.fromJson(payloadMap);
      } else {
        print('❌ Nenhum dado de usuário encontrado no token');
        return null;
      }
    } catch (e) {
      print('❌ Erro ao decodificar JWT: $e');
      return null;
    }
  }

  // Alterar senha
  Future<ApiResponse<void>> alterarSenha({
    required String senhaAtual,
    required String novaSenha,
    required String confirmarSenha,
  }) async {
    return await _apiService.put<void>(
      '/configuracoes/senha',
      data: {
        'senha_atual': senhaAtual,
        'nova_senha': novaSenha,
        'confirmar_senha': confirmarSenha,
      },
    );
  }

  // Buscar clientes disponíveis (para debug)
  Future<ApiResponse<List<ClienteInfo>>> buscarClientesDisponiveis() async {
    return await _clienteService.listarClientes(limite: 50);
  }

  // Buscar cliente por CPF
  Future<ApiResponse<ClienteInfo>> buscarClientePorCpf(String cpf) async {
    return await _clienteService.buscarClientePorCpf(cpf);
  }

  // Reset de senha (Esqueci minha senha) - ATUALIZADO: apenas CPF necessário
  Future<ApiResponse<ResetPasswordResponse>> resetPassword({
    required String cpf,
  }) async {
    // Configurar tenant antes da requisição
    final currentTenant = AppConfig.detectTenantFromCrm();
    await _apiService.setTenant(currentTenant);
    
    return await _apiService.post<ResetPasswordResponse>(
      '/auth/forgot-password',
      data: {
        'cpf': cpf,
      },
      fromJson: (data) => ResetPasswordResponse.fromJson(data),
    );
  }

}
