class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : json['data'],
      errors: json['errors'],
    );
  }

  bool get hasErrors => errors != null && errors!.isNotEmpty;
}

class Paginacao {
  final int total;
  final int paginaAtual;
  final int porPagina;
  final int totalPaginas;

  Paginacao({
    required this.total,
    required this.paginaAtual,
    required this.porPagina,
    required this.totalPaginas,
  });

  factory Paginacao.fromJson(Map<String, dynamic> json) {
    return Paginacao(
      total: json['total'],
      paginaAtual: json['pagina_atual'],
      porPagina: json['por_pagina'],
      totalPaginas: json['total_paginas'],
    );
  }
}

class LoginRequest {
  final String email;
  final String senha;
  final String dbGroup;

  LoginRequest({
    required this.email,
    required this.senha,
    required this.dbGroup,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'senha': senha,
      'db_group': dbGroup,
    };
  }
}

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

class VerificarCpfResponse {
  final bool existe;
  final User? paciente;

  VerificarCpfResponse({
    required this.existe,
    this.paciente,
  });

  factory VerificarCpfResponse.fromJson(Map<String, dynamic> json) {
    return VerificarCpfResponse(
      existe: json['existe'],
      paciente: json['paciente'] != null 
          ? User.fromJson(json['paciente']) 
          : null,
    );
  }
}
