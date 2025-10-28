import 'dart:convert';
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
    // Configurar tenant antes da requisição
    await _apiService.setTenant(dbGroup);

    final response = await _apiService.post<LoginResponse>(
      '/auth/login',
      data: LoginRequest(
        cpf: cpf,
        senha: senha,
        dbGroup: dbGroup,
      ).toJson(),
      fromJson: (data) => LoginResponse.fromJson(data),
    );

    // Salvar tokens se login foi bem-sucedido
    if (response.success && response.data != null) {
      await _apiService.saveToken(response.data!.token);
      await _apiService.saveRefreshToken(response.data!.refreshToken);
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
      data: VerificarCpfRequest(
        cpf: cpf,
        dbGroup: dbGroup,
      ).toJson(),
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
      if (token == null) return null;

      // Decodificar JWT para obter dados do usuário
      // Nota: Em produção, você deve validar o token no servidor
      // Aqui estamos apenas extraindo os dados para uso local
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);

      return User.fromJson(payloadMap);
    } catch (e) {
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
}
