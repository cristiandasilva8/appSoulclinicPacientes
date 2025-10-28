import '../models/api_response.dart';
import '../models/user.dart';
import '../models/agendamento.dart';
import 'api_service.dart';

class DashboardService {
  final ApiService _apiService = ApiService();

  // Dashboard principal
  Future<ApiResponse<DashboardData>> getDashboard({
    int? unidadeId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (unidadeId != null) {
      queryParams['unidade_id'] = unidadeId;
    }

    return await _apiService.get<DashboardData>(
      '/dashboard',
      queryParameters: queryParams,
      fromJson: (data) => DashboardData.fromJson(data),
    );
  }
}

class PerfilService {
  final ApiService _apiService = ApiService();

  // Buscar perfil
  Future<ApiResponse<User>> getPerfil() async {
    return await _apiService.get<User>(
      '/perfil',
      fromJson: (data) => User.fromJson(data),
    );
  }

  // Atualizar perfil
  Future<ApiResponse<void>> atualizarPerfil({
    required String nome,
    String? telefone,
    String? celular,
    Endereco? endereco,
    Preferencias? preferencias,
  }) async {
    final data = <String, dynamic>{
      'nome': nome,
    };

    if (telefone != null) data['telefone'] = telefone;
    if (celular != null) data['celular'] = celular;
    if (endereco != null) data['endereco'] = endereco.toJson();
    if (preferencias != null) data['preferencias'] = preferencias.toJson();

    return await _apiService.put<void>('/perfil', data: data);
  }

  // Upload de foto
  Future<ApiResponse<FotoResponse>> uploadFoto(String filePath) async {
    return await _apiService.uploadFile<FotoResponse>(
      '/perfil/foto',
      filePath,
      fieldName: 'foto',
      fromJson: (data) => FotoResponse.fromJson(data),
    );
  }
}

class AgendamentosService {
  final ApiService _apiService = ApiService();

  // Listar agendamentos
  Future<ApiResponse<AgendamentosResponse>> getAgendamentos({
    String? status,
    String? dataInicio,
    String? dataFim,
    String? tipo,
    int? pagina,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    if (dataInicio != null) queryParams['data_inicio'] = dataInicio;
    if (dataFim != null) queryParams['data_fim'] = dataFim;
    if (tipo != null) queryParams['tipo'] = tipo;
    if (pagina != null) queryParams['pagina'] = pagina;

    return await _apiService.get<AgendamentosResponse>(
      '/agendamentos',
      queryParameters: queryParams,
      fromJson: (data) => AgendamentosResponse.fromJson(data),
    );
  }

  // Detalhes do agendamento
  Future<ApiResponse<AgendamentoDetalhes>> getAgendamentoDetalhes(int id) async {
    return await _apiService.get<AgendamentoDetalhes>(
      '/agendamentos/$id',
      fromJson: (data) => AgendamentoDetalhes.fromJson(data),
    );
  }

  // Cancelar agendamento
  Future<ApiResponse<void>> cancelarAgendamento({
    required int id,
    required String motivo,
  }) async {
    return await _apiService.post<void>(
      '/agendamentos/$id/cancelar',
      data: {'motivo': motivo},
    );
  }

  // Solicitar agendamento
  Future<ApiResponse<SolicitacaoAgendamentoResponse>> solicitarAgendamento({
    required String tipo,
    required int especialidadeId,
    required int profissionalId,
    required int unidadeId,
    required String dataPreferencia,
    required String horaPreferencia,
    String? observacoes,
  }) async {
    final data = <String, dynamic>{
      'tipo': tipo,
      'especialidade_id': especialidadeId,
      'profissional_id': profissionalId,
      'unidade_id': unidadeId,
      'data_preferencia': dataPreferencia,
      'hora_preferencia': horaPreferencia,
    };

    if (observacoes != null) data['observacoes'] = observacoes;

    return await _apiService.post<SolicitacaoAgendamentoResponse>(
      '/agendamentos/solicitar',
      data: data,
      fromJson: (data) => SolicitacaoAgendamentoResponse.fromJson(data),
    );
  }
}

// Modelos específicos para os serviços

class DashboardData {
  final EstatisticasDashboard estatisticas;
  final List<Agendamento> proximosAgendamentos;
  final List<Notificacao> notificacoesRecentes;

  DashboardData({
    required this.estatisticas,
    required this.proximosAgendamentos,
    required this.notificacoesRecentes,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      estatisticas: EstatisticasDashboard.fromJson(json['estatisticas']),
      proximosAgendamentos: (json['proximos_agendamentos'] as List)
          .map((e) => Agendamento.fromJson(e))
          .toList(),
      notificacoesRecentes: (json['notificacoes_recentes'] as List)
          .map((e) => Notificacao.fromJson(e))
          .toList(),
    );
  }
}

class EstatisticasDashboard {
  final int totalAgendamentos;
  final int agendamentosHoje;
  final int agendamentosPendentes;
  final int agendamentosCancelados;
  final int totalConsultas;
  final int consultasMes;
  final int totalVacinas;
  final int vacinasPendentes;

  EstatisticasDashboard({
    required this.totalAgendamentos,
    required this.agendamentosHoje,
    required this.agendamentosPendentes,
    required this.agendamentosCancelados,
    required this.totalConsultas,
    required this.consultasMes,
    required this.totalVacinas,
    required this.vacinasPendentes,
  });

  factory EstatisticasDashboard.fromJson(Map<String, dynamic> json) {
    return EstatisticasDashboard(
      totalAgendamentos: json['total_agendamentos'],
      agendamentosHoje: json['agendamentos_hoje'],
      agendamentosPendentes: json['agendamentos_pendentes'],
      agendamentosCancelados: json['agendamentos_cancelados'],
      totalConsultas: json['total_consultas'],
      consultasMes: json['consultas_mes'],
      totalVacinas: json['total_vacinas'],
      vacinasPendentes: json['vacinas_pendentes'],
    );
  }
}

class Notificacao {
  final int id;
  final String titulo;
  final String mensagem;
  final DateTime data;
  final bool lida;

  Notificacao({
    required this.id,
    required this.titulo,
    required this.mensagem,
    required this.data,
    required this.lida,
  });

  factory Notificacao.fromJson(Map<String, dynamic> json) {
    return Notificacao(
      id: json['id'],
      titulo: json['titulo'],
      mensagem: json['mensagem'],
      data: DateTime.parse(json['data']),
      lida: json['lida'],
    );
  }
}

class AgendamentosResponse {
  final List<Agendamento> agendamentos;
  final Paginacao paginacao;

  AgendamentosResponse({
    required this.agendamentos,
    required this.paginacao,
  });

  factory AgendamentosResponse.fromJson(Map<String, dynamic> json) {
    return AgendamentosResponse(
      agendamentos: (json['agendamentos'] as List)
          .map((e) => Agendamento.fromJson(e))
          .toList(),
      paginacao: Paginacao.fromJson(json['paginacao']),
    );
  }
}

class FotoResponse {
  final String fotoUrl;

  FotoResponse({required this.fotoUrl});

  factory FotoResponse.fromJson(Map<String, dynamic> json) {
    return FotoResponse(fotoUrl: json['foto_url']);
  }
}

class SolicitacaoAgendamentoResponse {
  final String protocolo;

  SolicitacaoAgendamentoResponse({required this.protocolo});

  factory SolicitacaoAgendamentoResponse.fromJson(Map<String, dynamic> json) {
    return SolicitacaoAgendamentoResponse(protocolo: json['protocolo']);
  }
}
