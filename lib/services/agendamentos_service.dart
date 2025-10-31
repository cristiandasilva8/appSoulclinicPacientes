import '../models/api_response.dart';
import '../models/agendamento.dart';
import 'api_service.dart';

class AgendamentosService {
  final ApiService _apiService = ApiService();

  // Listar agendamentos
  Future<ApiResponse<Map<String, dynamic>>> getAgendamentos({
    String? status,
    String? dataInicio,
    String? dataFim,
    String? tipo,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (dataInicio != null) queryParams['data_inicio'] = dataInicio;
    if (dataFim != null) queryParams['data_fim'] = dataFim;
    if (tipo != null) queryParams['tipo'] = tipo;

    return await _apiService.get<Map<String, dynamic>>(
      '/agendamentos',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  // Detalhes do agendamento
  Future<ApiResponse<Agendamento>> getDetalhesAgendamento(int id) async {
    return await _apiService.get<Agendamento>(
      '/agendamentos/$id',
      fromJson: (data) => Agendamento.fromJson(data),
    );
  }

  // Cancelar agendamento
  Future<ApiResponse<void>> cancelarAgendamento(int id, {String? motivo}) async {
    return await _apiService.post<void>(
      '/agendamentos/$id/cancelar',
      data: motivo != null ? {'motivo': motivo} : {},
    );
  }

  // Solicitar agendamento
  Future<ApiResponse<Map<String, dynamic>>> solicitarAgendamento({
    required String tipo,
    required int especialidadeId,
    required int profissionalId,
    required int unidadeId,
    required String dataPreferencia,
    required String horaPreferencia,
    String? observacoes,
  }) async {
    return await _apiService.post<Map<String, dynamic>>(
      '/agendamentos/solicitar',
      data: {
        'tipo': tipo,
        'especialidade_id': especialidadeId,
        'profissional_id': profissionalId,
        'unidade_id': unidadeId,
        'data_preferencia': dataPreferencia,
        'hora_preferencia': horaPreferencia,
        if (observacoes != null) 'observacoes': observacoes,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}
