import 'user.dart';
import '../utils/json_utils.dart';

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
    // Processar aplicador - pode vir como string ou objeto
    String? aplicadorString;
    final aplicadorValue = json['aplicador'];
    
    if (aplicadorValue != null) {
      if (aplicadorValue is String) {
        // Já é uma string, usar diretamente
        aplicadorString = aplicadorValue.isEmpty ? null : aplicadorValue;
      } else if (aplicadorValue is Map) {
        // É um objeto JSON - extrair e formatar os campos
        final nome = aplicadorValue['nome'];
        final conselho = aplicadorValue['conselho'];
        final registro = aplicadorValue['registro'];
        final especialidade = aplicadorValue['especialidade'];
        
        // Criar lista de partes do aplicador (nome, registro do conselho, especialidade)
        final partes = <String>[];
        
        if (nome != null && nome.toString().isNotEmpty && nome.toString() != 'null') {
          partes.add(nome.toString());
        }
        
        if (conselho != null && conselho.toString().isNotEmpty && conselho.toString() != 'null') {
          if (registro != null && registro.toString().isNotEmpty && registro.toString() != 'null' && registro.toString() != '') {
            partes.add('$conselho $registro');
          } else {
            partes.add(conselho.toString());
          }
        } else if (registro != null && registro.toString().isNotEmpty && registro.toString() != 'null' && registro.toString() != '') {
          partes.add(registro.toString());
        }
        
        if (especialidade != null && especialidade.toString().isNotEmpty && especialidade.toString() != 'null' && especialidade.toString() != '') {
          partes.add(especialidade.toString());
        }
        
        // Se tiver pelo menos uma parte, juntar; senão, deixar null
        aplicadorString = partes.isNotEmpty ? partes.join(' - ') : null;
      } else {
        // Tentar converter para string
        final str = aplicadorValue.toString();
        aplicadorString = str.isEmpty || str == 'null' ? null : str;
      }
    }
    
    return Vacina(
      id: JsonUtils.safeInt(json['id']),
      nome: JsonUtils.safeString(json['nome']),
      dose: JsonUtils.safeString(json['dose']),
      dataAplicacao: JsonUtils.safeString(json['data_aplicacao']),
      dataProximaDose: JsonUtils.safeStringNullable(json['data_proxima_dose']),
      status: JsonUtils.safeString(json['status']),
      lote: JsonUtils.safeStringNullable(json['lote']),
      aplicador: aplicadorString,
      unidade: JsonUtils.safeStringNullable(json['unidade']),
      observacoes: JsonUtils.safeStringNullable(json['observacoes']),
      reacoesAdversas: JsonUtils.safeList(json['reacoes_adversas'], (e) => ReacaoAdversa.fromJson(e)),
      documentos: JsonUtils.safeList(json['documentos'], (e) => DocumentoVacina.fromJson(e)),
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
      id: JsonUtils.safeInt(json['id']),
      descricao: JsonUtils.safeString(json['descricao']),
      intensidade: JsonUtils.safeString(json['intensidade']),
      dataInicio: JsonUtils.safeString(json['data_inicio']),
      dataFim: JsonUtils.safeStringNullable(json['data_fim']),
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
      id: JsonUtils.safeInt(json['id']),
      nome: JsonUtils.safeString(json['nome']),
      url: JsonUtils.safeString(json['url']),
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
      vacinas: JsonUtils.safeList(json['vacinas'], (e) => Vacina.fromJson(e)),
      estatisticas: EstatisticasVacina.fromJson(json['estatisticas']),
    );
  }
}

class EstatisticasVacina {
  final int totalVacinas;
  final int vacinasAplicadas;
  final int vacinasPendentes;
  final int vacinasAtrasadas;

  EstatisticasVacina({
    required this.totalVacinas,
    required this.vacinasAplicadas,
    required this.vacinasPendentes,
    required this.vacinasAtrasadas,
  });

  factory EstatisticasVacina.fromJson(Map<String, dynamic> json) {
    return EstatisticasVacina(
      totalVacinas: JsonUtils.safeInt(json['total_vacinas']),
      vacinasAplicadas: JsonUtils.safeInt(json['vacinas_aplicadas'] ?? 0),
      vacinasPendentes: JsonUtils.safeInt(json['vacinas_pendentes']),
      vacinasAtrasadas: JsonUtils.safeInt(json['vacinas_atrasadas'] ?? 0),
    );
  }
}
