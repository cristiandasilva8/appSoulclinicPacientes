import '../utils/json_utils.dart';

class Agendamento {
  final int id;
  final String data;
  final String hora;
  final String tipo;
  final String profissional;
  final String unidade;
  final String? sala;
  final String status;
  final String? observacoes;
  final String? protocolo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Agendamento({
    required this.id,
    required this.data,
    required this.hora,
    required this.tipo,
    required this.profissional,
    required this.unidade,
    this.sala,
    required this.status,
    this.observacoes,
    this.protocolo,
    required this.createdAt,
    this.updatedAt,
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: JsonUtils.safeInt(json['id']),
      data: JsonUtils.safeString(json['data']),
      hora: JsonUtils.safeString(json['hora']),
      tipo: JsonUtils.safeString(json['tipo']),
      profissional: _extractProfissionalName(json['profissional']),
      unidade: _extractUnidadeName(json['unidade']),
      sala: JsonUtils.safeStringNullable(json['sala']),
      status: JsonUtils.safeString(json['status']),
      observacoes: JsonUtils.safeStringNullable(json['observacoes']),
      protocolo: JsonUtils.safeStringNullable(json['protocolo']),
      createdAt: JsonUtils.safeDateTime(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? JsonUtils.safeDateTime(json['updated_at']) 
          : null,
    );
  }

  static String _extractProfissionalName(dynamic profissional) {
    if (profissional == null) return '';
    if (profissional is String) return profissional;
    if (profissional is Map) {
      return JsonUtils.safeString(profissional['nome']);
    }
    return '';
  }

  static String _extractUnidadeName(dynamic unidade) {
    if (unidade == null) return '';
    if (unidade is String) return unidade;
    if (unidade is Map) {
      return JsonUtils.safeString(unidade['nome']);
    }
    return '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'hora': hora,
      'tipo': tipo,
      'profissional': profissional,
      'unidade': unidade,
      'sala': sala,
      'status': status,
      'observacoes': observacoes,
      'protocolo': protocolo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isAberto => status == 'aberto';
  bool get isEmAndamento => status == 'em_andamento';
  bool get isFinalizado => status == 'finalizado';
  bool get isNaoCompareceu => status == 'nao_compareceu';
  bool get isCanceladoPaciente => status == 'cancelado_paciente';
  bool get isCanceladoProfissional => status == 'cancelado_profissional';
  bool get isFaltaJustificada => status == 'falta_justificada';
  bool get isPedidoReserva => status == 'pedido_reserva';
  bool get isPacote => status == 'pacote';
  bool get isCancelado => isCanceladoPaciente || isCanceladoProfissional;
}

class AgendamentoDetalhes extends Agendamento {
  final ProfissionalDetalhes profissionalDetalhes;
  final UnidadeDetalhes unidadeDetalhes;

  AgendamentoDetalhes({
    required super.id,
    required super.data,
    required super.hora,
    required super.tipo,
    required super.profissional,
    required super.unidade,
    super.sala,
    required super.status,
    super.observacoes,
    super.protocolo,
    required super.createdAt,
    super.updatedAt,
    required this.profissionalDetalhes,
    required this.unidadeDetalhes,
  });

  factory AgendamentoDetalhes.fromJson(Map<String, dynamic> json) {
    return AgendamentoDetalhes(
      id: JsonUtils.safeInt(json['id']),
      data: JsonUtils.safeString(json['data']),
      hora: JsonUtils.safeString(json['hora']),
      tipo: JsonUtils.safeString(json['tipo']),
      profissional: _extractProfissionalName(json['profissional']),
      unidade: _extractUnidadeName(json['unidade']),
      sala: JsonUtils.safeStringNullable(json['sala']),
      status: JsonUtils.safeString(json['status']),
      observacoes: JsonUtils.safeStringNullable(json['observacoes']),
      protocolo: JsonUtils.safeStringNullable(json['protocolo']),
      createdAt: JsonUtils.safeDateTime(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? JsonUtils.safeDateTime(json['updated_at']) 
          : null,
      profissionalDetalhes: json['profissional'] != null
          ? ProfissionalDetalhes.fromJson(json['profissional'])
          : ProfissionalDetalhes(id: 0, nome: '', especialidade: 'Não informado', crm: 'Não informado'),
      unidadeDetalhes: json['unidade'] != null
          ? UnidadeDetalhes.fromJson(json['unidade'])
          : UnidadeDetalhes(id: 0, nome: '', endereco: 'Não informado', telefone: 'Não informado'),
    );
  }

  static String _extractProfissionalName(dynamic profissional) {
    if (profissional == null) return '';
    if (profissional is String) return profissional;
    if (profissional is Map) {
      return JsonUtils.safeString(profissional['nome']);
    }
    return '';
  }

  static String _extractUnidadeName(dynamic unidade) {
    if (unidade == null) return '';
    if (unidade is String) return unidade;
    if (unidade is Map) {
      return JsonUtils.safeString(unidade['nome']);
    }
    return '';
  }
}

class ProfissionalDetalhes {
  final int id;
  final String nome;
  final String especialidade;
  final String crm;

  ProfissionalDetalhes({
    required this.id,
    required this.nome,
    required this.especialidade,
    required this.crm,
  });

  factory ProfissionalDetalhes.fromJson(Map<String, dynamic> json) {
    return ProfissionalDetalhes(
      id: JsonUtils.safeInt(json['id']),
      nome: JsonUtils.safeString(json['nome']),
      especialidade: JsonUtils.safeString(json['especialidade'], defaultValue: 'Não informado'),
      crm: JsonUtils.safeString(json['crm'], defaultValue: 'Não informado'),
    );
  }
}

class UnidadeDetalhes {
  final int id;
  final String nome;
  final String endereco;
  final String telefone;

  UnidadeDetalhes({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.telefone,
  });

  factory UnidadeDetalhes.fromJson(Map<String, dynamic> json) {
    return UnidadeDetalhes(
      id: JsonUtils.safeInt(json['id']),
      nome: JsonUtils.safeString(json['nome']),
      endereco: JsonUtils.safeString(json['endereco'], defaultValue: 'Não informado'),
      telefone: JsonUtils.safeString(json['telefone'], defaultValue: 'Não informado'),
    );
  }
}
