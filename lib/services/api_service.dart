import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/user.dart';

class ApiService {
  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _dbGroupKey = 'db_group';
  
  late Dio _dio;
  String? _currentDbGroup;

  ApiService() {
    _dio = Dio();
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Adicionar token de autorização se disponível
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          // Adicionar headers padrão
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          
          handler.next(options);
        },
        onError: (error, handler) async {
          // Tratar erro 401 - token expirado
          if (error.response?.statusCode == 401) {
            final refreshed = await refreshToken();
            if (refreshed) {
              // Tentar novamente a requisição
              final token = await getToken();
              if (token != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              }
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
  }

  // Salvar refresh token
  Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  // Obter token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Obter refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Renovar token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/auth/refresh',
        data: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final refreshResponse = RefreshTokenResponse.fromJson(data['data']);
          await saveToken(refreshResponse.token);
          await saveRefreshToken(refreshResponse.refreshToken);
          return true;
        }
      }
      return false;
    } catch (e) {
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

  // GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
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
      final response = await _dio.put(path, data: data);
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(path);
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
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

    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        message = data['message'] ?? message;
        errors = data['errors'];
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      message = 'Timeout de conexão';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      message = 'Timeout de recebimento';
    }

    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
    );
  }
}
