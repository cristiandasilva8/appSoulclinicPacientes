import '../models/api_response.dart';
import 'api_service.dart';

class ConfiguracoesService {
  final ApiService _apiService = ApiService();

  /// Buscar configurações do paciente
  Future<ApiResponse<Map<String, dynamic>>> buscarConfiguracoes() async {
    return await _apiService.get<Map<String, dynamic>>(
      '/configuracoes',
      fromJson: (data) => data,
    );
  }

  /// Alterar senha
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

  /// Atualizar configurações de notificação
  Future<ApiResponse<void>> atualizarNotificacoes({
    required bool email,
    required bool sms,
    required bool push,
    required bool lembretesAgendamento,
    required bool lembretesVacina,
    required bool novidades,
  }) async {
    return await _apiService.put<void>(
      '/configuracoes/notificacoes',
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

  /// Solicitar exclusão de conta
  Future<ApiResponse<void>> solicitarExclusaoConta() async {
    return await _apiService.post<void>(
      '/configuracoes/solicitar-exclusao',
    );
  }

  /// Retirar pedido de exclusão de conta
  Future<ApiResponse<void>> retirarPedidoExclusao() async {
    return await _apiService.post<void>(
      '/configuracoes/retirar-pedido-exclusao',
    );
  }
}