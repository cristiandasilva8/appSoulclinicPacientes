import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../models/vacina.dart';
import '../services/carteira_vacinacao_service.dart';

class CarteiraVacinacaoScreen extends StatefulWidget {
  const CarteiraVacinacaoScreen({super.key});

  @override
  State<CarteiraVacinacaoScreen> createState() => _CarteiraVacinacaoScreenState();
}

class _CarteiraVacinacaoScreenState extends State<CarteiraVacinacaoScreen> {
  final CarteiraVacinacaoService _carteiraService = CarteiraVacinacaoService();
  bool _isLoading = true;
  CarteiraVacinacao? _carteira;
  String _filtroSelecionado = 'total'; // 'total', 'aplicadas', 'pendentes', 'atrasadas'

  @override
  void initState() {
    super.initState();
    _loadCarteira();
  }

  Future<void> _loadCarteira({String? filtro}) async {
    // Usar filtro do parâmetro ou o filtro selecionado
    final filtroAUsar = filtro ?? _filtroSelecionado;
    
    setState(() {
      _isLoading = true;
      _filtroSelecionado = filtroAUsar;
    });

    try {
      final response = await _carteiraService.buscarCarteira(
        filtro: filtroAUsar == 'total' ? null : filtroAUsar,
      );
      
      if (response.success && response.data != null) {
        try {
          print('🔍 Dados da carteira recebidos (filtro: $filtroAUsar): ${response.data}');
          
          // Normalizar dados antes de processar
          final Map<String, dynamic> normalizedData = _normalizeCarteiraData(response.data!);
          print('🔍 Dados normalizados: $normalizedData');
          
          setState(() {
            _carteira = CarteiraVacinacao.fromJson(normalizedData);
            _isLoading = false;
          });
          
          print('✅ Carteira carregada com ${_carteira!.vacinas.length} vacinas (filtro: $filtroAUsar)');
        } catch (parseError) {
          print('❌ Erro ao processar dados da carteira: $parseError');
          print('📄 Dados recebidos: ${response.data}');
          _showErrorSnackBar('Erro ao processar dados da carteira. Tente novamente.');
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
      print('Erro ao carregar carteira: $e');
      _showErrorSnackBar('Erro ao carregar carteira. Verifique sua conexão e tente novamente.');
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

  // Normalizar dados da carteira para estrutura consistente
  Map<String, dynamic> _normalizeCarteiraData(Map<String, dynamic> data) {
    final Map<String, dynamic> normalized = Map<String, dynamic>.from(data);
    
    // Garantir que vacinas seja uma lista
    if (normalized['vacinas'] == null) {
      normalized['vacinas'] = [];
    } else if (normalized['vacinas'] is! List) {
      normalized['vacinas'] = [];
    }
    
    // Garantir que estatisticas seja um objeto
    if (normalized['estatisticas'] == null) {
      normalized['estatisticas'] = <String, dynamic>{
        'total_vacinas': 0,
        'vacinas_aplicadas': 0,
        'vacinas_pendentes': 0,
        'vacinas_atrasadas': 0,
      };
    } else if (normalized['estatisticas'] is List) {
      // Se estatísticas vieram como lista, converter para objeto
      if ((normalized['estatisticas'] as List).isNotEmpty) {
        final firstStats = (normalized['estatisticas'] as List).first as Map<String, dynamic>;
        // Garantir que vacinas_aplicadas existe
        if (!firstStats.containsKey('vacinas_aplicadas')) {
          firstStats['vacinas_aplicadas'] = 0;
        }
        normalized['estatisticas'] = firstStats;
      } else {
        normalized['estatisticas'] = <String, dynamic>{
          'total_vacinas': 0,
          'vacinas_aplicadas': 0,
          'vacinas_pendentes': 0,
          'vacinas_atrasadas': 0,
        };
      }
    } else if (normalized['estatisticas'] is Map) {
      // Garantir que vacinas_aplicadas existe no objeto
      final stats = normalized['estatisticas'] as Map<String, dynamic>;
      if (!stats.containsKey('vacinas_aplicadas')) {
        stats['vacinas_aplicadas'] = 0;
      }
      if (!stats.containsKey('vacinas_atrasadas')) {
        stats['vacinas_atrasadas'] = 0;
      }
    }
    
    // Garantir que paciente seja um objeto
    if (normalized['paciente'] == null) {
      normalized['paciente'] = <String, dynamic>{
        'id': 0,
        'nome': 'Paciente',
        'email': 'usuario@exemplo.com',
        'cpf': '000.000.000-00',
        'sexo': 'N/A',
        'db_group': 'group_clinica_dutra_65',
      };
    } else {
      // Garantir campos obrigatórios no paciente existente
      final paciente = normalized['paciente'] as Map<String, dynamic>;
      paciente['email'] = paciente['email'] ?? 'usuario@exemplo.com';
      paciente['cpf'] = paciente['cpf'] ?? '000.000.000-00';
      paciente['sexo'] = paciente['sexo'] ?? 'N/A';
      paciente['db_group'] = paciente['db_group'] ?? 'group_clinica_dutra_65';
    }
    
    return normalized;
  }

  Future<void> _gerarPdf() async {
    try {
      final response = await _carteiraService.gerarPdf();
      if (response.success && response.data != null) {
        final pdfUrl = response.data!['pdf_url'];
        if (pdfUrl != null) {
          final uri = Uri.parse(pdfUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            _showErrorSnackBar('Não foi possível abrir o PDF');
          }
        }
      } else {
        _showErrorSnackBar(response.message);
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao gerar PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carteira de Vacinação'),
        backgroundColor: Color(AppConfig.currentTenant.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _gerarPdf,
            tooltip: 'Gerar PDF',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadCarteira(),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _carteira == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Erro ao carregar carteira de vacinação',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadCarteira,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar Novamente'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(AppConfig.currentTenant.primaryColor),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Estatísticas
        _buildEstatisticas(),
        
        // Filtros
        _buildFiltros(),
        
        // Lista de vacinas
        Expanded(
          child: _carteira!.vacinas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.vaccines_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma vacina encontrada',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (_filtroSelecionado != 'total') ...[
                        const SizedBox(height: 8),
                        Text(
                          'com o filtro "${_getFiltroLabel(_filtroSelecionado)}"',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _carteira!.vacinas.length,
                  itemBuilder: (context, index) {
                    return _buildVacinaCard(_carteira!.vacinas[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFiltros() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFiltroChip('total', 'Todas', Icons.vaccines),
            const SizedBox(width: 8),
            _buildFiltroChip('aplicadas', 'Aplicadas', Icons.check_circle),
            const SizedBox(width: 8),
            _buildFiltroChip('pendentes', 'Pendentes', Icons.schedule),
            const SizedBox(width: 8),
            _buildFiltroChip('atrasadas', 'Atrasadas', Icons.warning),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltroChip(String filtro, String label, IconData icon) {
    final isSelected = _filtroSelecionado == filtro;
    final color = _getFiltroColor(filtro);
    
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : color),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected && _filtroSelecionado != filtro) {
          _loadCarteira(filtro: filtro);
        }
      },
    );
  }

  String _getFiltroLabel(String filtro) {
    switch (filtro) {
      case 'aplicadas':
        return 'Aplicadas';
      case 'pendentes':
        return 'Pendentes';
      case 'atrasadas':
        return 'Atrasadas';
      default:
        return 'Todas';
    }
  }

  Color _getFiltroColor(String filtro) {
    switch (filtro) {
      case 'aplicadas':
        return Colors.green;
      case 'pendentes':
        return Colors.orange;
      case 'atrasadas':
        return Colors.red;
      default:
        return Color(AppConfig.currentTenant.primaryColor);
    }
  }

  Widget _buildEstatisticas() {
    final stats = _carteira!.estatisticas;
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
              'Total',
              stats.totalVacinas.toString(),
              Icons.vaccines,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Aplicadas',
              stats.vacinasAplicadas.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Pendentes',
              stats.vacinasPendentes.toString(),
              Icons.schedule,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Atrasadas',
              stats.vacinasAtrasadas.toString(),
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
            fontSize: 20,
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

  Widget _buildVacinaCard(Vacina vacina) {
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
                  _getVacinaIcon(vacina.status),
                  color: _getVacinaColor(vacina.status),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vacina.nome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        vacina.dose,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getVacinaColor(vacina.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    vacina.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getVacinaColor(vacina.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (vacina.dataAplicacao.isNotEmpty) ...[
              _buildInfoRow('Data de Aplicação', vacina.dataAplicacao),
            ],
            if (vacina.dataProximaDose != null && vacina.dataProximaDose!.isNotEmpty) ...[
              _buildInfoRow('Próxima Dose', vacina.dataProximaDose!),
            ],
            if (vacina.lote != null && vacina.lote!.isNotEmpty) ...[
              _buildInfoRow('Lote', vacina.lote!),
            ],
            // Exibir aplicador apenas se tiver dados válidos
            // Se aplicador for null ou string vazia ou contiver apenas "null", não exibir
            if (vacina.aplicador != null && 
                vacina.aplicador!.isNotEmpty && 
                vacina.aplicador!.trim().toLowerCase() != 'null' &&
                !vacina.aplicador!.trim().startsWith('{')) ...[
              _buildInfoRow('Aplicador', vacina.aplicador!),
            ],
            if (vacina.unidade != null && vacina.unidade!.isNotEmpty) ...[
              _buildInfoRow('Unidade', vacina.unidade!),
            ],
            if (vacina.observacoes != null && vacina.observacoes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Observações:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                vacina.observacoes!,
                style: const TextStyle(fontSize: 12),
              ),
            ],
            if (vacina.documentos.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Documentos:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              ...vacina.documentos.map((doc) => ListTile(
                dense: true,
                leading: const Icon(Icons.description, size: 16),
                title: Text(doc.nome, style: const TextStyle(fontSize: 12)),
                onTap: () => _abrirDocumento(doc.url),
              )),
            ],
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
            width: 100,
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

  IconData _getVacinaIcon(String status) {
    switch (status.toLowerCase()) {
      case 'aplicada':
        return Icons.check_circle;
      case 'pendente':
        return Icons.schedule;
      case 'atrasada':
        return Icons.warning;
      default:
        return Icons.vaccines;
    }
  }

  Color _getVacinaColor(String status) {
    switch (status.toLowerCase()) {
      case 'aplicada':
        return Colors.green;
      case 'pendente':
        return Colors.orange;
      case 'atrasada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _abrirDocumento(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackBar('Não foi possível abrir o documento');
    }
  }
}
