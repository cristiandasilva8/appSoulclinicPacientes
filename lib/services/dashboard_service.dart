import '../models/api_response.dart';
import 'api_service.dart';

class DashboardService {
  final ApiService _apiService = ApiService();

  // Buscar dados do dashboard
  Future<ApiResponse<DashboardData>> getDashboard({int? unidadeId}) async {
    final queryParams = <String, String>{};
    if (unidadeId != null) {
      queryParams['unidade_id'] = unidadeId.toString();
    }

    return await _apiService.get<DashboardData>(
      '/dashboard',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) {
        print('🔍 Dashboard response data type: ${data.runtimeType}');
        print('🔍 Dashboard response data: $data');
        
        try {
          // Se a API retorna diretamente os dados do dashboard
          if (data is Map<String, dynamic>) {
            print('🔍 Processando dados do dashboard...');
            
            // Normalizar estrutura de dados
            final Map<String, dynamic> normalizedData = _normalizeDashboardData(data);
            print('🔍 Dados normalizados: $normalizedData');
            
            return DashboardData.fromJson(normalizedData);
          }
          // Se a API retorna uma lista (caso de erro)
          else if (data is List) {
            print('❌ API retornou List em vez de Map - criando dados vazios');
            return _createEmptyDashboardData();
          }
          // Caso inesperado
          else {
            print('❌ Tipo de dados inesperado: ${data.runtimeType}');
            return _createEmptyDashboardData();
          }
        } catch (e) {
          print('❌ Erro ao processar dados do dashboard: $e');
          return _createEmptyDashboardData();
        }
      },
    );
  }

  // Normalizar dados do dashboard para estrutura consistente
  Map<String, dynamic> _normalizeDashboardData(Map<String, dynamic> data) {
    final Map<String, dynamic> normalized = Map<String, dynamic>.from(data);
    
    // Normalizar estatísticas
    if (data['estatisticas'] == null) {
      normalized['estatisticas'] = <String, dynamic>{};
    } else if (data['estatisticas'] is List) {
      // Se estatísticas vieram como lista vazia, converter para objeto vazio
      if ((data['estatisticas'] as List).isEmpty) {
        normalized['estatisticas'] = <String, dynamic>{};
      } else {
        // Se tem dados na lista, tentar converter para objeto
        final statsList = data['estatisticas'] as List;
        if (statsList.isNotEmpty && statsList.first is Map<String, dynamic>) {
          normalized['estatisticas'] = statsList.first;
        } else {
          normalized['estatisticas'] = <String, dynamic>{};
        }
      }
    }
    
    // Garantir que proximos_agendamentos seja uma lista
    if (normalized['proximos_agendamentos'] == null) {
      normalized['proximos_agendamentos'] = [];
    } else if (normalized['proximos_agendamentos'] is! List) {
      normalized['proximos_agendamentos'] = [];
    }
    
    // Garantir que notificacoes_recentes seja uma lista
    if (normalized['notificacoes_recentes'] == null) {
      normalized['notificacoes_recentes'] = [];
    } else if (normalized['notificacoes_recentes'] is! List) {
      normalized['notificacoes_recentes'] = [];
    }
    
    return normalized;
  }

  // Criar dados vazios do dashboard
  DashboardData _createEmptyDashboardData() {
    return DashboardData(
      estatisticas: Estatisticas(
        totalAgendamentos: 0,
        agendamentosHoje: 0,
        agendamentosPendentes: 0,
        agendamentosCancelados: 0,
        totalConsultas: 0,
        consultasMes: 0,
        totalVacinas: 0,
        vacinasPendentes: 0,
      ),
      proximosAgendamentos: [],
      notificacoesRecentes: [],
    );
  }
}

// Modelos de dados do Dashboard
class DashboardData {
  final Estatisticas estatisticas;
  final List<ProximoAgendamento> proximosAgendamentos;
  final List<NotificacaoRecente> notificacoesRecentes;

  DashboardData({
    required this.estatisticas,
    required this.proximosAgendamentos,
    required this.notificacoesRecentes,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      estatisticas: Estatisticas.fromJson(json['estatisticas']),
      proximosAgendamentos: (json['proximos_agendamentos'] as List)
          .map((e) => ProximoAgendamento.fromJson(e))
          .toList(),
      notificacoesRecentes: (json['notificacoes_recentes'] as List)
          .map((e) => NotificacaoRecente.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estatisticas': estatisticas.toJson(),
      'proximos_agendamentos': proximosAgendamentos.map((e) => e.toJson()).toList(),
      'notificacoes_recentes': notificacoesRecentes.map((e) => e.toJson()).toList(),
    };
  }
}

class Estatisticas {
  final int totalAgendamentos;
  final int agendamentosHoje;
  final int agendamentosPendentes;
  final int agendamentosCancelados;
  final int totalConsultas;
  final int consultasMes;
  final int totalVacinas;
  final int vacinasPendentes;

  Estatisticas({
    required this.totalAgendamentos,
    required this.agendamentosHoje,
    required this.agendamentosPendentes,
    required this.agendamentosCancelados,
    required this.totalConsultas,
    required this.consultasMes,
    required this.totalVacinas,
    required this.vacinasPendentes,
  });

  factory Estatisticas.fromJson(Map<String, dynamic> json) {
    print('🔍 Estatisticas.fromJson recebido: $json');
    print('🔍 Tipo do json: ${json.runtimeType}');
    
    return Estatisticas(
      totalAgendamentos: json['total_agendamentos'] ?? 0,
      agendamentosHoje: json['agendamentos_hoje'] ?? json['agendamentos_confirmados'] ?? 0,
      agendamentosPendentes: json['agendamentos_pendentes'] ?? 0,
      agendamentosCancelados: json['agendamentos_cancelados'] ?? 0,
      totalConsultas: json['total_consultas'] ?? json['proximas_consultas'] ?? 0,
      consultasMes: json['consultas_mes'] ?? 0,
      totalVacinas: json['total_vacinas'] ?? 0,
      vacinasPendentes: json['vacinas_pendentes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_agendamentos': totalAgendamentos,
      'agendamentos_hoje': agendamentosHoje,
      'agendamentos_pendentes': agendamentosPendentes,
      'agendamentos_cancelados': agendamentosCancelados,
      'total_consultas': totalConsultas,
      'consultas_mes': consultasMes,
      'total_vacinas': totalVacinas,
      'vacinas_pendentes': vacinasPendentes,
    };
  }
}

class ProximoAgendamento {
  final int id;
  final String data;
  final String hora;
  final String tipo;
  final String profissional;
  final String unidade;
  final String status;

  ProximoAgendamento({
    required this.id,
    required this.data,
    required this.hora,
    required this.tipo,
    required this.profissional,
    required this.unidade,
    required this.status,
  });

  factory ProximoAgendamento.fromJson(Map<String, dynamic> json) {
    return ProximoAgendamento(
      id: json['id'],
      data: json['data'],
      hora: json['hora'],
      tipo: json['tipo'],
      profissional: json['profissional'],
      unidade: json['unidade'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'hora': hora,
      'tipo': tipo,
      'profissional': profissional,
      'unidade': unidade,
      'status': status,
    };
  }
}

class NotificacaoRecente {
  final int id;
  final String titulo;
  final String mensagem;
  final String data;
  final bool lida;

  NotificacaoRecente({
    required this.id,
    required this.titulo,
    required this.mensagem,
    required this.data,
    required this.lida,
  });

  factory NotificacaoRecente.fromJson(Map<String, dynamic> json) {
    return NotificacaoRecente(
      id: json['id'],
      titulo: json['titulo'],
      mensagem: json['mensagem'],
      data: json['data'],
      lida: json['lida'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'mensagem': mensagem,
      'data': data,
      'lida': lida,
    };
  }
}