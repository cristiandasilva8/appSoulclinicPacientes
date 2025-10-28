import 'user.dart';

class Vacina {
  final int id;
  final String nome;
  final String dose;
  final String dataAplicacao;
  final String? dataProximaDose;
  final String status;
  final String? lote;
  final String? aplicador;
  final String? unidade;
  final String? observacoes;
  final List<ReacaoAdversa> reacoesAdversas;
  final List<DocumentoVacina> documentos;

  Vacina({
    required this.id,
    required this.nome,
    required this.dose,
    required this.dataAplicacao,
    this.dataProximaDose,
    required this.status,
    this.lote,
    this.aplicador,
    this.unidade,
    this.observacoes,
    this.reacoesAdversas = const [],
    this.documentos = const [],
  });

  factory Vacina.fromJson(Map<String, dynamic> json) {
    return Vacina(
      id: json['id'],
      nome: json['nome'],
      dose: json['dose'],
      dataAplicacao: json['data_aplicacao'],
      dataProximaDose: json['data_proxima_dose'],
      status: json['status'],
      lote: json['lote'],
      aplicador: json['aplicador'],
      unidade: json['unidade'],
      observacoes: json['observacoes'],
      reacoesAdversas: json['reacoes_adversas'] != null
          ? (json['reacoes_adversas'] as List)
              .map((e) => ReacaoAdversa.fromJson(e))
              .toList()
          : [],
      documentos: json['documentos'] != null
          ? (json['documentos'] as List)
              .map((e) => DocumentoVacina.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'dose': dose,
      'data_aplicacao': dataAplicacao,
      'data_proxima_dose': dataProximaDose,
      'status': status,
      'lote': lote,
      'aplicador': aplicador,
      'unidade': unidade,
      'observacoes': observacoes,
      'reacoes_adversas': reacoesAdversas.map((e) => e.toJson()).toList(),
      'documentos': documentos.map((e) => e.toJson()).toList(),
    };
  }

  bool get isAplicada => status == 'aplicada';
  bool get isPendente => status == 'pendente';
  bool get isAtrasada => status == 'atrasada';
}

class ReacaoAdversa {
  final int id;
  final String descricao;
  final String intensidade;
  final String dataInicio;
  final String? dataFim;

  ReacaoAdversa({
    required this.id,
    required this.descricao,
    required this.intensidade,
    required this.dataInicio,
    this.dataFim,
  });

  factory ReacaoAdversa.fromJson(Map<String, dynamic> json) {
    return ReacaoAdversa(
      id: json['id'],
      descricao: json['descricao'],
      intensidade: json['intensidade'],
      dataInicio: json['data_inicio'],
      dataFim: json['data_fim'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'intensidade': intensidade,
      'data_inicio': dataInicio,
      'data_fim': dataFim,
    };
  }
}

class DocumentoVacina {
  final int id;
  final String nome;
  final String url;

  DocumentoVacina({
    required this.id,
    required this.nome,
    required this.url,
  });

  factory DocumentoVacina.fromJson(Map<String, dynamic> json) {
    return DocumentoVacina(
      id: json['id'],
      nome: json['nome'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'url': url,
    };
  }
}

class CarteiraVacinacao {
  final User paciente;
  final List<Vacina> vacinas;
  final EstatisticasVacina estatisticas;

  CarteiraVacinacao({
    required this.paciente,
    required this.vacinas,
    required this.estatisticas,
  });

  factory CarteiraVacinacao.fromJson(Map<String, dynamic> json) {
    return CarteiraVacinacao(
      paciente: User.fromJson(json['paciente']),
      vacinas: (json['vacinas'] as List)
          .map((e) => Vacina.fromJson(e))
          .toList(),
      estatisticas: EstatisticasVacina.fromJson(json['estatisticas']),
    );
  }
}

class EstatisticasVacina {
  final int totalVacinas;
  final int vacinasPendentes;
  final int vacinasAtrasadas;

  EstatisticasVacina({
    required this.totalVacinas,
    required this.vacinasPendentes,
    required this.vacinasAtrasadas,
  });

  factory EstatisticasVacina.fromJson(Map<String, dynamic> json) {
    return EstatisticasVacina(
      totalVacinas: json['total_vacinas'],
      vacinasPendentes: json['vacinas_pendentes'],
      vacinasAtrasadas: json['vacinas_atrasadas'],
    );
  }
}
