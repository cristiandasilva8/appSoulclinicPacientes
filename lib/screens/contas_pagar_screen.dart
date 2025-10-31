import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../services/contas_pagar_service.dart';

class ContasPagarScreen extends StatefulWidget {
  const ContasPagarScreen({super.key});

  @override
  State<ContasPagarScreen> createState() => _ContasPagarScreenState();
}

class _ContasPagarScreenState extends State<ContasPagarScreen> {
  final ContasPagarService _contasService = ContasPagarService();
  bool _isLoading = true;
  List<dynamic> _contas = [];
  Map<String, dynamic>? _estatisticas;
  String _filtroStatus = 'todas';
  String _filtroDataInicio = '';
  String _filtroDataFim = '';

  final List<String> _statusOptions = [
    'todas',
    'pendentes',
    'pagas',
    'vencidas',
  ];

  @override
  void initState() {
    super.initState();
    _loadContas();
  }

  Future<void> _loadContas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _contasService.listarContas(
        status: _filtroStatus == 'todas' ? null : _filtroStatus,
        dataInicio: _filtroDataInicio.isEmpty ? null : _filtroDataInicio,
        dataFim: _filtroDataFim.isEmpty ? null : _filtroDataFim,
      );

      if (response.success && response.data != null) {
        try {
          print('🔍 Dados de contas recebidos: ${response.data}');
          
          // Normalizar dados antes de processar
          final Map<String, dynamic> normalizedData = _normalizeContasData(response.data!);
          print('🔍 Dados normalizados: $normalizedData');
          
          setState(() {
            _contas = normalizedData['contas'] ?? [];
            _estatisticas = normalizedData['estatisticas'];
            _isLoading = false;
          });
          
          print('✅ ${_contas.length} contas carregadas com sucesso');
        } catch (parseError) {
          print('❌ Erro ao processar dados das contas: $parseError');
          _showErrorSnackBar('Erro ao processar dados das contas. Tente novamente.');
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        _showErrorSnackBar(response.message);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao carregar contas: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Normalizar dados das contas para estrutura consistente
  Map<String, dynamic> _normalizeContasData(Map<String, dynamic> data) {
    final Map<String, dynamic> normalized = Map<String, dynamic>.from(data);
    
    // Garantir que contas seja uma lista
    if (normalized['contas'] == null) {
      normalized['contas'] = [];
    } else if (normalized['contas'] is! List) {
      normalized['contas'] = [];
    }
    
    // Garantir que estatisticas seja um objeto
    if (normalized['estatisticas'] == null) {
      normalized['estatisticas'] = <String, dynamic>{
        'total_pendente': 0.0,
        'total_pago': 0.0,
        'total_vencido': 0.0,
      };
    } else if (normalized['estatisticas'] is List) {
      // Se estatísticas vieram como lista, converter para objeto
      if ((normalized['estatisticas'] as List).isNotEmpty) {
        normalized['estatisticas'] = (normalized['estatisticas'] as List).first;
      } else {
        normalized['estatisticas'] = <String, dynamic>{
          'total_pendente': 0.0,
          'total_pago': 0.0,
          'total_vencido': 0.0,
        };
      }
    }
    
    return normalized;
  }

  Future<void> _gerarCobranca(int contaId) async {
    try {
      final response = await _contasService.gerarCobranca(
        contaId: contaId,
        formaPagamento: 'boleto',
        dataVencimento: DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0],
      );

      if (response.success && response.data != null) {
        _showCobrancaDialog(response.data!);
      } else {
        _showErrorSnackBar(response.message);
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao gerar cobrança: $e');
    }
  }

  void _showCobrancaDialog(Map<String, dynamic> cobranca) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cobrança Gerada'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (cobranca['boleto'] != null) ...[
                const Text('Boleto:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Linha Digitável: ${cobranca['boleto']['linha_digitavel'] ?? ''}'),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _abrirUrl(cobranca['boleto']['pdf_url']),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Abrir Boleto PDF'),
                ),
                const SizedBox(height: 16),
              ],
              if (cobranca['pix'] != null) ...[
                const Text('PIX:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text('QR Code PIX:'),
                      const SizedBox(height: 8),
                      if (cobranca['pix']['qr_code'] != null)
                        Image.network(
                          cobranca['pix']['qr_code'],
                          height: 200,
                          width: 200,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text('Erro ao carregar QR Code');
                          },
                        ),
                      const SizedBox(height: 8),
                      Text(
                        cobranca['pix']['qr_code_text'] ?? '',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirUrl(String? url) async {
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Não foi possível abrir o link');
      }
    }
  }

  void _showFiltros() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _filtroStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: _statusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusLabel(status)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _filtroStatus = value ?? 'todas';
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Data Início (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _filtroDataInicio = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Data Fim (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _filtroDataFim = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadContas();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'todas':
        return 'Todas';
      case 'pendentes':
        return 'Pendentes';
      case 'pagas':
        return 'Pagas';
      case 'vencidas':
        return 'Vencidas';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas a Pagar'),
        backgroundColor: Color(AppConfig.currentTenant.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFiltros,
            tooltip: 'Filtros',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContas,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Estatísticas
                if (_estatisticas != null) _buildEstatisticas(),
                
                // Lista de contas
                Expanded(
                  child: _contas.isEmpty
                      ? const Center(
                          child: Text('Nenhuma conta encontrada'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _contas.length,
                          itemBuilder: (context, index) {
                            return _buildContaCard(_contas[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEstatisticas() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(AppConfig.currentTenant.primaryColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        border: Border.all(
          color: Color(AppConfig.currentTenant.primaryColor).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Pendente',
              'R\$ ${_estatisticas!['total_pendente']?.toStringAsFixed(2) ?? '0,00'}',
              Icons.schedule,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Pago',
              'R\$ ${_estatisticas!['total_pago']?.toStringAsFixed(2) ?? '0,00'}',
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Vencido',
              'R\$ ${_estatisticas!['total_vencido']?.toStringAsFixed(2) ?? '0,00'}',
              Icons.warning,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildContaCard(Map<String, dynamic> conta) {
    final String status = conta['status'] ?? '';
    final double valor = (conta['valor'] ?? 0.0).toDouble();
    final String dataVencimento = conta['data_vencimento'] ?? '';
    final String? dataPagamento = conta['data_pagamento'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(status),
                  color: _getStatusColor(status),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conta['descricao'] ?? 'Sem descrição',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (conta['protocolo'] != null)
                        Text(
                          'Protocolo: ${conta['protocolo']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow('Valor', 'R\$ ${valor.toStringAsFixed(2)}'),
                ),
                Expanded(
                  child: _buildInfoRow('Vencimento', _formatDate(dataVencimento)),
                ),
              ],
            ),
            if (dataPagamento != null)
              _buildInfoRow('Pagamento', _formatDate(dataPagamento)),
            if (conta['forma_pagamento'] != null)
              _buildInfoRow('Forma de Pagamento', conta['forma_pagamento']),
            const SizedBox(height: 12),
            if (status == 'pendente' || status == 'vencida')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _gerarCobranca(conta['id']),
                  icon: const Icon(Icons.payment),
                  label: const Text('Gerar Cobrança'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppConfig.currentTenant.primaryColor),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paga':
        return Icons.check_circle;
      case 'pendente':
        return Icons.schedule;
      case 'vencida':
        return Icons.warning;
      default:
        return Icons.receipt;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paga':
        return Colors.green;
      case 'pendente':
        return Colors.orange;
      case 'vencida':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
