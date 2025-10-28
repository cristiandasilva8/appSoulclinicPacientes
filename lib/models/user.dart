class User {
  final int id;
  final String nome;
  final String email;
  final String cpf;
  final String? telefone;
  final String? celular;
  final String dataNascimento;
  final String sexo;
  final String dbGroup;
  final Endereco? endereco;
  final String? fotoUrl;
  final Preferencias? preferencias;

  User({
    required this.id,
    required this.nome,
    required this.email,
    required this.cpf,
    this.telefone,
    this.celular,
    required this.dataNascimento,
    required this.sexo,
    required this.dbGroup,
    this.endereco,
    this.fotoUrl,
    this.preferencias,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      cpf: json['cpf'],
      telefone: json['telefone'],
      celular: json['celular'],
      dataNascimento: json['data_nascimento'],
      sexo: json['sexo'],
      dbGroup: json['db_group'],
      endereco: json['endereco'] != null 
          ? Endereco.fromJson(json['endereco']) 
          : null,
      fotoUrl: json['foto_url'],
      preferencias: json['preferencias'] != null 
          ? Preferencias.fromJson(json['preferencias']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'celular': celular,
      'data_nascimento': dataNascimento,
      'sexo': sexo,
      'db_group': dbGroup,
      'endereco': endereco?.toJson(),
      'foto_url': fotoUrl,
      'preferencias': preferencias?.toJson(),
    };
  }

  User copyWith({
    int? id,
    String? nome,
    String? email,
    String? cpf,
    String? telefone,
    String? celular,
    String? dataNascimento,
    String? sexo,
    String? dbGroup,
    Endereco? endereco,
    String? fotoUrl,
    Preferencias? preferencias,
  }) {
    return User(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      telefone: telefone ?? this.telefone,
      celular: celular ?? this.celular,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      sexo: sexo ?? this.sexo,
      dbGroup: dbGroup ?? this.dbGroup,
      endereco: endereco ?? this.endereco,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      preferencias: preferencias ?? this.preferencias,
    );
  }
}

class Endereco {
  final String cep;
  final String logradouro;
  final String numero;
  final String? complemento;
  final String bairro;
  final String cidade;
  final String estado;

  Endereco({
    required this.cep,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
      cep: json['cep'],
      logradouro: json['logradouro'],
      numero: json['numero'],
      complemento: json['complemento'],
      bairro: json['bairro'],
      cidade: json['cidade'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
    };
  }
}

class Preferencias {
  final bool notificacoesEmail;
  final bool notificacoesSms;
  final bool notificacoesPush;

  Preferencias({
    required this.notificacoesEmail,
    required this.notificacoesSms,
    required this.notificacoesPush,
  });

  factory Preferencias.fromJson(Map<String, dynamic> json) {
    return Preferencias(
      notificacoesEmail: json['notificacoes_email'] ?? true,
      notificacoesSms: json['notificacoes_sms'] ?? true,
      notificacoesPush: json['notificacoes_push'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificacoes_email': notificacoesEmail,
      'notificacoes_sms': notificacoesSms,
      'notificacoes_push': notificacoesPush,
    };
  }

  Preferencias copyWith({
    bool? notificacoesEmail,
    bool? notificacoesSms,
    bool? notificacoesPush,
  }) {
    return Preferencias(
      notificacoesEmail: notificacoesEmail ?? this.notificacoesEmail,
      notificacoesSms: notificacoesSms ?? this.notificacoesSms,
      notificacoesPush: notificacoesPush ?? this.notificacoesPush,
    );
  }
}
