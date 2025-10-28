import '../models/api_response.dart';
import 'api_service.dart';

class ClienteService {
  final ApiService _apiService = ApiService();

  // Buscar cliente por CPF
  Future<ApiResponse<ClienteInfo>> buscarClientePorCpf(String cpf) async {
    return await _apiService.get<ClienteInfo>(
      '/clientes/buscar-por-cpf',
      queryParameters: {'cpf': cpf},
      fromJson: (data) => ClienteInfo.fromJson(data),
    );
  }

  // Listar clientes disponíveis (para debug)
  Future<ApiResponse<List<ClienteInfo>>> listarClientes({
    int? pagina,
    int? limite,
  }) async {
    final queryParams = <String, dynamic>{};
    if (pagina != null) queryParams['pagina'] = pagina;
    if (limite != null) queryParams['limite'] = limite;

    return await _apiService.get<List<ClienteInfo>>(
      '/clientes',
      queryParameters: queryParams,
      fromJson: (data) => (data as List).map((e) => ClienteInfo.fromJson(e)).toList(),
    );
  }
}

class ClienteInfo {
  final int id;
  final String nome;
  final String email;
  final String cpf;
  final String? telefone;
  final String? celular;
  final String? cnpj;
  final String? razaoSocial;
  final bool ativo;
  final bool bloqueado;
  final String? dbGroup;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ClienteInfo({
    required this.id,
    required this.nome,
    required this.email,
    required this.cpf,
    this.telefone,
    this.celular,
    this.cnpj,
    this.razaoSocial,
    required this.ativo,
    required this.bloqueado,
    this.dbGroup,
    required this.createdAt,
    this.updatedAt,
  });

  factory ClienteInfo.fromJson(Map<String, dynamic> json) {
    return ClienteInfo(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      cpf: json['cpf'],
      telefone: json['telefone'],
      celular: json['celular'],
      cnpj: json['cnpj'],
      razaoSocial: json['razao_social'],
      ativo: json['ativo'] ?? true,
      bloqueado: json['bloqueado'] ?? false,
      dbGroup: json['db_group'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
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
      'cnpj': cnpj,
      'razao_social': razaoSocial,
      'ativo': ativo,
      'bloqueado': bloqueado,
      'db_group': dbGroup,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isAtivo => ativo && !bloqueado;
  String get displayName => razaoSocial ?? nome;
}
