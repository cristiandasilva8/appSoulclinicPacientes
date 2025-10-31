import '../models/api_response.dart';
import '../models/vacina.dart';
import 'api_service.dart';

class CarteiraVacinacaoService {
  final ApiService _apiService = ApiService();

  /// Buscar carteira de vacinação do paciente
  Future<ApiResponse<Map<String, dynamic>>> buscarCarteira() async {
    return await _apiService.get<Map<String, dynamic>>(
      '/carteira-vacinacao',
      fromJson: (data) => data,
    );
  }

  /// Buscar detalhes de uma vacina específica
  Future<ApiResponse<Vacina>> buscarDetalhesVacina(int vacinaId) async {
    return await _apiService.get<Vacina>(
      '/carteira-vacinacao/detalhes/$vacinaId',
      fromJson: (data) => Vacina.fromJson(data),
    );
  }

  /// Gerar PDF da carteira de vacinação
  Future<ApiResponse<Map<String, dynamic>>> gerarPdf() async {
    return await _apiService.get<Map<String, dynamic>>(
      '/carteira-vacinacao/pdf',
      fromJson: (data) => data,
    );
  }
}