import 'user.dart';

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
    try {
      return ApiResponse<T>(
        success: json['success'] ?? false,
        message: json['message'] ?? 'Resposta sem mensagem',
        data: json['data'] != null && fromJsonT != null 
            ? fromJsonT(json['data']) 
            : json['data'],
        errors: json['errors'],
      );
    } catch (e) {
      print('❌ Erro ao processar ApiResponse: $e');
      print('❌ JSON recebido: $json');
      return ApiResponse<T>(
        success: false,
        message: 'Erro ao processar resposta: ${e.toString()}',
        data: null,
        errors: null,
      );
    }
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

