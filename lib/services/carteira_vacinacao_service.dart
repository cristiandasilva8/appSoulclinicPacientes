import '../models/api_response.dart';
import '../models/vacina.dart';
import 'api_service.dart';

class CarteiraVacinacaoService {
  final ApiService _apiService = ApiService();

  /// Buscar carteira de vacinação do paciente
  /// [filtro] pode ser: 'total', 'aplicadas', 'pendentes', 'atrasadas'
  Future<ApiResponse<Map<String, dynamic>>> buscarCarteira({String? filtro}) async {
    final queryParameters = filtro != null && filtro != 'total'
        ? {'filtro': filtro}
        : null;
    
    return await _apiService.get<Map<String, dynamic>>(
      '/carteira-vacinacao',
      queryParameters: queryParameters,
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