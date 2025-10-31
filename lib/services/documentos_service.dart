import '../models/api_response.dart';
import 'api_service.dart';

class DocumentosService {
  final ApiService _apiService = ApiService();

  /// Listar documentos do paciente
  Future<ApiResponse<Map<String, dynamic>>> listarDocumentos({
    String? tipo,
    String? dataInicio,
    String? dataFim,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (tipo != null) queryParameters['tipo'] = tipo;
    if (dataInicio != null) queryParameters['data_inicio'] = dataInicio;
    if (dataFim != null) queryParameters['data_fim'] = dataFim;

    return await _apiService.get<Map<String, dynamic>>(
      '/documentos',
      queryParameters: queryParameters,
      fromJson: (data) => data,
    );
  }

  /// Download de documento
  Future<ApiResponse<Map<String, dynamic>>> downloadDocumento(int documentoId) async {
    return await _apiService.get<Map<String, dynamic>>(
      '/documentos/$documentoId/download',
      fromJson: (data) => data,
    );
  }
}