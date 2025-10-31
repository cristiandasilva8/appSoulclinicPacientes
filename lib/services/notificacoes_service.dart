import '../models/api_response.dart';
import 'api_service.dart';

class NotificacoesService {
  final ApiService _apiService = ApiService();

  /// Listar notificações do paciente
  Future<ApiResponse<Map<String, dynamic>>> listarNotificacoes({
    String? status,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (status != null) queryParameters['status'] = status;

    return await _apiService.get<Map<String, dynamic>>(
      '/notificacoes',
      queryParameters: queryParameters,
      fromJson: (data) => data,
    );
  }

  /// Marcar notificação como lida
  Future<ApiResponse<void>> marcarComoLida(int notificacaoId) async {
    return await _apiService.put<void>(
      '/notificacoes/$notificacaoId/ler',
    );
  }

  /// Atualizar configurações de notificação
  Future<ApiResponse<void>> atualizarConfiguracoes({
    required bool email,
    required bool sms,
    required bool push,
    required bool lembretesAgendamento,
    required bool lembretesVacina,
    required bool novidades,
  }) async {
    return await _apiService.put<void>(
      '/notificacoes/configuracoes',
      data: {
        'email': email,
        'sms': sms,
        'push': push,
        'lembretes_agendamento': lembretesAgendamento,
        'lembretes_vacina': lembretesVacina,
        'novidades': novidades,
      },
    );
  }
}