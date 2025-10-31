import '../utils/json_utils.dart';

class User {
  final int id;
  final String nome;
  final String email;
  final String cpf;
  final String? telefone;
  final String? celular;
  final String? dataNascimento;
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
    this.dataNascimento,
    required this.sexo,
    required this.dbGroup,
    this.endereco,
    this.fotoUrl,
    this.preferencias,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 User.fromJson recebido: $json');
      
      // Validar campos obrigatórios
      final id = JsonUtils.safeInt(json['id']);
      final nome = JsonUtils.safeString(json['nome']);
      final email = JsonUtils.safeString(json['email']);
      final cpf = JsonUtils.safeString(json['cpf']);
      final sexo = JsonUtils.safeString(json['genero'] ?? json['sexo']);
      final dbGroup = JsonUtils.safeString(json['db_group']);
      
      if (id == 0) {
        print('❌ ID do usuário é obrigatório');
        throw Exception('ID do usuário é obrigatório');
      }
      
      if (nome.isEmpty) {
        print('❌ Nome do usuário é obrigatório');
        throw Exception('Nome do usuário é obrigatório');
      }
      
      if (email.isEmpty) {
        print('❌ Email do usuário é obrigatório');
        throw Exception('Email do usuário é obrigatório');
      }
      
      if (cpf.isEmpty) {
        print('❌ CPF do usuário é obrigatório');
        throw Exception('CPF do usuário é obrigatório');
      }
      
      // Sexo pode ser vazio - usar valor padrão se não vier
      final finalSexo = sexo.isEmpty ? 'N' : sexo;
      
      // DB Group pode ser vazio se não vier da API (usar valor padrão)
      final finalDbGroup = dbGroup.isEmpty ? 'default' : dbGroup;
      
      return User(
        id: id,
        nome: nome,
        email: email,
        cpf: cpf,
        telefone: JsonUtils.safeStringNullable(json['telefone']),
        celular: JsonUtils.safeStringNullable(json['celular']),
        dataNascimento: JsonUtils.safeStringNullable(json['data_nascimento']),
        sexo: finalSexo,
        dbGroup: finalDbGroup,
        endereco: _buildEnderecoFromPerfil(json),
        fotoUrl: JsonUtils.safeStringNullable(json['foto']),
        preferencias: json['preferencias'] != null 
            ? Preferencias.fromJson(json['preferencias']) 
            : null,
      );
    } catch (e) {
      print('❌ Erro ao criar User: $e');
      print('❌ JSON recebido: $json');
      rethrow;
    }
  }

  static Endereco? _buildEnderecoFromPerfil(Map<String, dynamic> json) {
    final cep = JsonUtils.safeString(json['cep']);
    final logradouro = JsonUtils.safeString(json['logradouro']);
    final numero = JsonUtils.safeString(json['numero']);
    final bairro = JsonUtils.safeString(json['bairro']);
    final cidade = JsonUtils.safeString(json['cidade']);
    final uf = JsonUtils.safeString(json['uf']);
    
    // Só cria endereço se tiver pelo menos alguns dados
    if (cep.isNotEmpty || logradouro.isNotEmpty || cidade.isNotEmpty) {
      return Endereco(
        cep: cep,
        logradouro: logradouro,
        numero: numero,
        complemento: JsonUtils.safeStringNullable(json['complemento']),
        bairro: bairro,
        cidade: cidade,
        estado: uf,
      );
    }
    return null;
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
      cep: JsonUtils.safeString(json['cep']),
      logradouro: JsonUtils.safeString(json['logradouro']),
      numero: JsonUtils.safeString(json['numero']),
      complemento: JsonUtils.safeStringNullable(json['complemento']),
      bairro: JsonUtils.safeString(json['bairro']),
      cidade: JsonUtils.safeString(json['cidade']),
      estado: JsonUtils.safeString(json['estado']),
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

// Classes para resposta de login
class LoginResponse {
  final String token;
  final String refreshToken;
  final User user;

  LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      refreshToken: json['refresh_token'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refresh_token': refreshToken,
      'user': user.toJson(),
    };
  }
}

class RefreshTokenResponse {
  final String token;
  final String refreshToken;

  RefreshTokenResponse({
    required this.token,
    required this.refreshToken,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      token: json['token'],
      refreshToken: json['refresh_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refresh_token': refreshToken,
    };
  }
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {
      'refresh_token': refreshToken,
    };
  }
}

class VerificarCpfResponse {
  final bool existe;
  final User? paciente;

  VerificarCpfResponse({
    required this.existe,
    this.paciente,
  });

  factory VerificarCpfResponse.fromJson(Map<String, dynamic> json) {
    return VerificarCpfResponse(
      existe: json['existe'] ?? false,
      paciente: json['paciente'] != null ? User.fromJson(json['paciente']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'existe': existe,
      'paciente': paciente?.toJson(),
    };
  }
}

class VerificarCpfRequest {
  final String cpf;
  final String dbGroup;

  VerificarCpfRequest({
    required this.cpf,
    required this.dbGroup,
  });

  Map<String, dynamic> toJson() {
    return {
      'cpf': cpf,
      'db_group': dbGroup,
    };
  }
}

class ResetPasswordResponse {
  final bool emailEnviado;
  final String? emailErro;
  final String? pacienteEmail;
  final String? pacienteNome;

  ResetPasswordResponse({
    required this.emailEnviado,
    this.emailErro,
    this.pacienteEmail,
    this.pacienteNome,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      emailEnviado: json['email_enviado'] ?? false,
      emailErro: json['email_erro'],
      pacienteEmail: json['paciente_email'],
      pacienteNome: json['paciente_nome'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email_enviado': emailEnviado,
      'email_erro': emailErro,
      'paciente_email': pacienteEmail,
      'paciente_nome': pacienteNome,
    };
  }
}
