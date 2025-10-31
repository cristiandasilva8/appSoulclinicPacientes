import '../models/api_response.dart';
import '../models/user.dart';
import 'api_service.dart';

class PerfilService {
  final ApiService _apiService = ApiService();

  // Buscar perfil do usuário
  Future<ApiResponse<User>> getPerfil() async {
    return await _apiService.get<User>(
      '/perfil',
      fromJson: (data) => User.fromJson(data),
    );
  }

  // Atualizar perfil
  Future<ApiResponse<void>> atualizarPerfil(Map<String, dynamic> dados) async {
    return await _apiService.put<void>(
      '/perfil',
      data: dados,
    );
  }

  // Upload de foto
  Future<ApiResponse<Map<String, dynamic>>> uploadFoto(String filePath) async {
    return await _apiService.uploadFile<Map<String, dynamic>>(
      '/perfil/foto',
      filePath,
      fieldName: 'foto',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}
