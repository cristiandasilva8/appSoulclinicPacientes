import '../models/api_response.dart';
import 'api_service.dart';

class ContasPagarService {
  final ApiService _apiService = ApiService();

  /// Listar contas a pagar do paciente
  Future<ApiResponse<Map<String, dynamic>>> listarContas({
    String? status,
    String? dataInicio,
    String? dataFim,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (status != null) queryParameters['status'] = status;
    if (dataInicio != null) queryParameters['data_inicio'] = dataInicio;
    if (dataFim != null) queryParameters['data_fim'] = dataFim;

    return await _apiService.get<Map<String, dynamic>>(
      '/contas-pagar',
      queryParameters: queryParameters,
      fromJson: (data) => data,
    );
  }

  /// Buscar detalhes de uma conta
  Future<ApiResponse<Map<String, dynamic>>> buscarDetalhesConta(int contaId) async {
    return await _apiService.get<Map<String, dynamic>>(
      '/contas-pagar/$contaId',
      fromJson: (data) => data,
    );
  }

  /// Gerar cobrança para uma conta
  Future<ApiResponse<Map<String, dynamic>>> gerarCobranca({
    required int contaId,
    required String formaPagamento,
    required String dataVencimento,
  }) async {
    return await _apiService.post<Map<String, dynamic>>(
      '/contas-pagar/$contaId/gerar-cobranca',
      data: {
        'forma_pagamento': formaPagamento,
        'data_vencimento': dataVencimento,
      },
      fromJson: (data) => data,
    );
  }
}