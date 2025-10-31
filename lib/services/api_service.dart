import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';

class ApiService {
  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _dbGroupKey = 'db_group';
  
  late Dio _dio;
  String? _currentDbGroup;
  bool _isRefreshing = false; // Flag para prevenir múltiplas tentativas de refresh simultâneas

  ApiService() {
    _dio = Dio();
    _initializeBaseUrl();
    _setupInterceptors();
  }

  // Inicializar URL base
  void _initializeBaseUrl() {
    // Usar URL padrão do tenant atual
    final tenantConfig = AppConfig.currentTenant;
    _dio.options.baseUrl = tenantConfig.baseUrl;
    _dio.options.connectTimeout = Duration(seconds: AppConfig.requestTimeoutSeconds);
    _dio.options.receiveTimeout = Duration(seconds: AppConfig.requestTimeoutSeconds);
    _dio.options.sendTimeout = Duration(seconds: AppConfig.requestTimeoutSeconds);
    print('🌐 URL Base configurada: ${tenantConfig.baseUrl}');
    print('⏱️ Timeouts configurados: ${AppConfig.requestTimeoutSeconds}s');
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Adicionar token de autorização se disponível
          final token = await getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            print('🔑 Token encontrado e enviado: ${token.length > 20 ? token.substring(0, 20) : token}...');
          } else {
            print('⚠️ Token NÃO encontrado ou vazio - requisição será enviada sem token');
          }
          
          // Adicionar headers padrão
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          
          print('📤 URL: ${options.uri}');
          print('📤 Method: ${options.method}');
          print('📤 Headers Authorization: ${options.headers['Authorization'] != null ? 'Bearer ***' : 'NÃO ENVIADO'}');
          handler.next(options);
        },
        onError: (error, handler) async {
          // Tratar erro 401 - token expirado
          if (error.response?.statusCode == 401) {
            print('🔒 Erro 401 detectado - Token expirado ou inválido');
            
            // Verificar se a mensagem indica token inválido
            final errorMessage = error.response?.data?['message'] ?? '';
            final isTokenInvalid = errorMessage.toLowerCase().contains('token inválido') ||
                                  errorMessage.toLowerCase().contains('token expirado');
            
            // Verificar se o refresh token existe antes de tentar renovar
            final refreshTokenExists = await getRefreshToken();
            final hasValidRefreshToken = refreshTokenExists != null && 
                                        refreshTokenExists.isNotEmpty && 
                                        refreshTokenExists != 'refresh_token_placeholder';
            
            // Se já está tentando fazer refresh, evitar loop infinito
            if (_isRefreshing) {
              print('⚠️ Refresh já em andamento, aguardando...');
              // Aguardar um pouco e tentar novamente
              await Future.delayed(const Duration(milliseconds: 500));
              if (_isRefreshing) {
                print('❌ Refresh ainda em andamento, passando erro adiante');
                handler.next(error);
                return;
              }
            }
            
            // Tentar fazer refresh do token apenas se:
            // 1. Não está em refresh
            // 2. É erro de token inválido/expirado
            // 3. Tem refresh token válido
            if (!_isRefreshing && isTokenInvalid && hasValidRefreshToken) {
              _isRefreshing = true;
              try {
                print('🔄 Tentando renovar token...');
                final refreshed = await refreshToken();
                
                if (refreshed) {
                  print('✅ Token renovado com sucesso');
                  // Tentar novamente a requisição
                  final token = await getToken();
                  if (token != null) {
                    error.requestOptions.headers['Authorization'] = 'Bearer $token';
                    final response = await _dio.fetch(error.requestOptions);
                    _isRefreshing = false;
                    handler.resolve(response);
                    return;
                  } else {
                    print('❌ Token renovado mas não encontrado após salvar');
                    // Não limpar tokens aqui, deixar que a tela trate o erro
                  }
                } else {
                  print('❌ Falha ao renovar token - deixando tokens intactos');
                  // Não limpar tokens automaticamente - deixar que a tela trate o erro
                }
              } catch (e) {
                print('❌ Erro ao renovar token: $e');
                // Não limpar tokens automaticamente - deixar que a tela trate o erro
              } finally {
                _isRefreshing = false;
              }
            } else if (!hasValidRefreshToken && isTokenInvalid) {
              print('⚠️ Token expirado e sem refresh token válido - limpando tokens para forçar novo login');
              // Limpar tokens para forçar o usuário a fazer login novamente
              await clearTokens();
            } else {
              print('⚠️ Erro 401 mas não é erro de token inválido - passando erro adiante');
              // Não limpar tokens - deixar que a tela trate o erro
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  // Configurar tenant atual
  Future<void> setTenant(String dbGroup) async {
    _currentDbGroup = dbGroup;
    final tenantConfig = AppConfig.tenants[dbGroup];
    if (tenantConfig != null) {
      _dio.options.baseUrl = tenantConfig.baseUrl;
      print('🔄 Tenant configurado: $dbGroup -> ${tenantConfig.baseUrl}');
    } else {
      print('❌ Tenant não encontrado: $dbGroup');
    }
    
    // Salvar no SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dbGroupKey, dbGroup);
  }

  // Obter tenant atual
  Future<String?> getCurrentTenant() async {
    if (_currentDbGroup != null) return _currentDbGroup;
    
    final prefs = await SharedPreferences.getInstance();
    _currentDbGroup = prefs.getString(_dbGroupKey);
    return _currentDbGroup;
  }

  // Obter URL base do tenant atual
  Future<String> getBaseUrl() async {
    final dbGroup = await getCurrentTenant();
    if (dbGroup != null && AppConfig.tenants.containsKey(dbGroup)) {
      return AppConfig.tenants[dbGroup]!.baseUrl;
    }
    return AppConfig.tenants['soulclinic']!.baseUrl; // Default
  }

  // Salvar token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print('💾 Token salvo com sucesso (tamanho: ${token.length} caracteres)');
    // Verificar se foi salvo corretamente
    final savedToken = await prefs.getString(_tokenKey);
    if (savedToken != null && savedToken == token) {
      print('✅ Token verificado - salvo corretamente');
    } else {
      print('❌ ERRO: Token não foi salvo corretamente!');
    }
  }

  // Salvar refresh token
  Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  // Obter token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    // Apenas logar quando não há token (para debug)
    if (token == null || token.isEmpty) {
      print('❌ Token NÃO encontrado no SharedPreferences');
    }
    return token;
  }

  // Obter refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Renovar token
  Future<bool> refreshToken() async {
    try {
      final refreshTokenValue = await getRefreshToken();
      if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
        print('❌ Refresh token não encontrado ou vazio');
        return false;
      }

      print('🔄 Fazendo requisição de refresh token...');
      final response = await _dio.post(
        '/auth/refresh',
        data: {
          'refresh_token': refreshTokenValue,
        },
        options: Options(
          validateStatus: (status) => status! < 500, // Não lançar exceção para 4xx
        ),
      );

      print('📡 Resposta do refresh: status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          final refreshData = data['data'];
          if (refreshData != null && refreshData['token'] != null) {
            await saveToken(refreshData['token']);
            if (refreshData['refresh_token'] != null) {
              await saveRefreshToken(refreshData['refresh_token']);
            }
            print('✅ Token renovado e salvo com sucesso');
            return true;
          }
        }
      }
      
      print('❌ Refresh token falhou: status=${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Erro ao renovar token: $e');
      return false;
    }
  }

  // Limpar tokens
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // Verificar se está autenticado
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Testar conectividade com o servidor
  Future<bool> testConnectivity() async {
    try {
      print('🔍 Testando conectividade com: ${_dio.options.baseUrl}');
      // Testar endpoint do dashboard que sabemos que funciona
      final response = await _dio.get('/dashboard', options: Options(
        receiveTimeout: Duration(seconds: 5),
        sendTimeout: Duration(seconds: 5),
      ));
      print('✅ Servidor online: ${response.statusCode}');
      return true;
    } catch (e) {
      print('❌ Servidor offline ou inacessível: $e');
      // Se falhar, tentar sem o teste de conectividade
      print('⚠️ Pulando teste de conectividade, tentando login diretamente...');
      return true; // Retornar true para permitir tentar o login
    }
  }

  // GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      print('🚀 API Request: GET ${_dio.options.baseUrl}$path');
      if (queryParameters != null) {
        print('📋 Query Parameters: $queryParameters');
      }
      
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      
      print('✅ API Response: ${response.statusCode}');
      print('📄 Response Data: ${response.data}');
      
      // Verificar se a resposta é válida
      if (response.data == null) {
        print('❌ Resposta vazia da API');
        return ApiResponse<T>(
          success: false,
          message: 'Resposta vazia do servidor',
        );
      }
      
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      print('❌ API Error: ${e.message}');
      print('❌ Error Type: ${e.type}');
      print('❌ Response: ${e.response?.data}');
      return _handleError(e);
    } catch (e) {
      print('❌ Erro inesperado: $e');
      return ApiResponse<T>(
        success: false,
        message: 'Erro inesperado: ${e.toString()}',
      );
    }
  }

  // POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      print('🚀 API Request: POST ${_dio.options.baseUrl}$path');
      print('📦 Data: $data');
      
      final response = await _dio.post(path, data: data);
      
      print('✅ API Response: ${response.statusCode}');
      print('📄 Response Data: ${response.data}');
      
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      print('❌ API Error: ${e.message}');
      print('❌ Error Type: ${e.type}');
      print('❌ Response: ${e.response?.data}');
      return _handleError(e);
    }
  }

  // PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      print('🚀 API Request: PUT ${_dio.options.baseUrl}$path');
      print('📦 Data: $data');
      
      final response = await _dio.put(path, data: data);
      
      print('✅ API Response: ${response.statusCode}');
      print('📄 Response Data: ${response.data}');
      
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      print('❌ API Error: ${e.message}');
      print('❌ Error Type: ${e.type}');
      print('❌ Response: ${e.response?.data}');
      return _handleError(e);
    }
  }

  // DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      print('🚀 API Request: DELETE ${_dio.options.baseUrl}$path');
      
      final response = await _dio.delete(path);
      
      print('✅ API Response: ${response.statusCode}');
      print('📄 Response Data: ${response.data}');
      
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      print('❌ API Error: ${e.message}');
      print('❌ Error Type: ${e.type}');
      print('❌ Response: ${e.response?.data}');
      return _handleError(e);
    }
  }

  // Upload de arquivo
  Future<ApiResponse<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?additionalData,
      });

      final response = await _dio.post(path, data: formData);
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Tratar erros
  ApiResponse<T> _handleError<T>(DioException e) {
    String message = 'Erro de conexão';
    Map<String, dynamic>? errors;

    print('❌ DioException Type: ${e.type}');
    print('❌ DioException Message: ${e.message}');
    print('❌ DioException Response: ${e.response?.data}');

    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        message = data['message'] ?? message;
        errors = data['errors'];
        
        // Se for erro 401 e não tiver mensagem, adicionar mensagem padrão
        if (e.response!.statusCode == 401 && message == 'Erro de conexão') {
          message = 'Token inválido ou expirado';
        }
      } else if (data is String) {
        message = data;
      }
    } else {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          message = 'Timeout de conexão - Verifique sua internet';
          break;
        case DioExceptionType.receiveTimeout:
          message = 'Timeout de recebimento - Servidor demorou para responder';
          break;
        case DioExceptionType.sendTimeout:
          message = 'Timeout de envio - Dados não foram enviados';
          break;
        case DioExceptionType.connectionError:
          message = 'Erro de conexão - Verifique se o servidor está online';
          break;
        case DioExceptionType.badResponse:
          // Manter mensagem original se disponível
          if (e.response?.statusCode == 401) {
            message = 'Token inválido ou expirado';
          } else {
            message = 'Resposta inválida do servidor';
          }
          break;
        case DioExceptionType.cancel:
          message = 'Requisição cancelada';
          break;
        case DioExceptionType.unknown:
          message = 'Erro desconhecido - Verifique sua conexão';
          break;
        default:
          message = 'Erro de conexão';
      }
    }

    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
    );
  }
}
