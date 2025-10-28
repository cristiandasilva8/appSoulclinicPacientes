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
      id: json['id'],
      data: json['data'],
      hora: json['hora'],
      tipo: json['tipo'],
      profissional: json['profissional'],
      unidade: json['unidade'],
      sala: json['sala'],
      status: json['status'],
      observacoes: json['observacoes'],
      protocolo: json['protocolo'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
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
      'sala': sala,
      'status': status,
      'observacoes': observacoes,
      'protocolo': protocolo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isConfirmado => status == 'confirmado';
  bool get isPendente => status == 'pendente';
  bool get isCancelado => status == 'cancelado';
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
      id: json['id'],
      data: json['data'],
      hora: json['hora'],
      tipo: json['tipo'],
      profissional: json['profissional']['nome'],
      unidade: json['unidade']['nome'],
      sala: json['sala'],
      status: json['status'],
      observacoes: json['observacoes'],
      protocolo: json['protocolo'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      profissionalDetalhes: ProfissionalDetalhes.fromJson(json['profissional']),
      unidadeDetalhes: UnidadeDetalhes.fromJson(json['unidade']),
    );
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
      id: json['id'],
      nome: json['nome'],
      especialidade: json['especialidade'],
      crm: json['crm'],
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
      id: json['id'],
      nome: json['nome'],
      endereco: json['endereco'],
      telefone: json['telefone'],
    );
  }
}
