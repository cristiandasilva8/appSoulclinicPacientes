import '../models/api_response.dart';
import 'api_service.dart';

class MensagensService {
  final ApiService _apiService = ApiService();

  /// Listar mensagens do paciente
  Future<ApiResponse<Map<String, dynamic>>> listarMensagens({
    String? status,
    String? tipo,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (status != null) queryParameters['status'] = status;
    if (tipo != null) queryParameters['tipo'] = tipo;

    return await _apiService.get<Map<String, dynamic>>(
      '/mensagens',
      queryParameters: queryParameters,
      fromJson: (data) => data,
    );
  }

  /// Buscar detalhes de uma mensagem
  Future<ApiResponse<Map<String, dynamic>>> buscarDetalhesMensagem(int mensagemId) async {
    return await _apiService.get<Map<String, dynamic>>(
      '/mensagens/$mensagemId',
      fromJson: (data) => data,
    );
  }

  /// Marcar mensagem como lida
  Future<ApiResponse<void>> marcarComoLida(int mensagemId) async {
    return await _apiService.put<void>(
      '/mensagens/$mensagemId/ler',
    );
  }

  /// Enviar mensagem
  Future<ApiResponse<Map<String, dynamic>>> enviarMensagem({
    required int destinatarioId,
    required String assunto,
    required String mensagem,
    String? prioridade,
  }) async {
    return await _apiService.post<Map<String, dynamic>>(
      '/mensagens',
      data: {
        'destinatario_id': destinatarioId,
        'assunto': assunto,
        'mensagem': mensagem,
        'prioridade': prioridade ?? 'normal',
      },
      fromJson: (data) => data,
    );
  }
}