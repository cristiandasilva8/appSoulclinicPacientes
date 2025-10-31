import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../services/documentos_service.dart';

class DocumentosScreen extends StatefulWidget {
  const DocumentosScreen({super.key});

  @override
  State<DocumentosScreen> createState() => _DocumentosScreenState();
}

class _DocumentosScreenState extends State<DocumentosScreen> {
  final DocumentosService _documentosService = DocumentosService();
  bool _isLoading = true;
  List<dynamic> _documentos = [];
  String _filtroTipo = 'todos';
  String _filtroDataInicio = '';
  String _filtroDataFim = '';

  final List<String> _tiposDocumento = [
    'todos',
    'exame',
    'receita',
    'atestado',
    'relatorio',
  ];

  @override
  void initState() {
    super.initState();
    _loadDocumentos();
  }

  Future<void> _loadDocumentos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _documentosService.listarDocumentos(
        tipo: _filtroTipo == 'todos' ? null : _filtroTipo,
        dataInicio: _filtroDataInicio.isEmpty ? null : _filtroDataInicio,
        dataFim: _filtroDataFim.isEmpty ? null : _filtroDataFim,
      );

      if (response.success && response.data != null) {
        setState(() {
          _documentos = response.data!['documentos'] ?? [];
          _isLoading = false;
        });
      } else {
        _showErrorSnackBar(response.message);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao carregar documentos: $e');
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

  Future<void> _downloadDocumento(int documentoId) async {
    try {
      final response = await _documentosService.downloadDocumento(documentoId);
      if (response.success && response.data != null) {
        final downloadUrl = response.data!['download_url'];
        if (downloadUrl != null) {
          final uri = Uri.parse(downloadUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            _showErrorSnackBar('Não foi possível abrir o documento');
          }
        }
      } else {
        _showErrorSnackBar(response.message);
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao baixar documento: $e');
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
              value: _filtroTipo,
              decoration: const InputDecoration(
                labelText: 'Tipo de Documento',
                border: OutlineInputBorder(),
              ),
              items: _tiposDocumento.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(tipo == 'todos' ? 'Todos' : tipo.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _filtroTipo = value ?? 'todos';
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
              _loadDocumentos();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentos'),
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
            onPressed: _loadDocumentos,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _documentos.isEmpty
              ? const Center(
                  child: Text('Nenhum documento encontrado'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _documentos.length,
                  itemBuilder: (context, index) {
                    return _buildDocumentoCard(_documentos[index]);
                  },
                ),
    );
  }

  Widget _buildDocumentoCard(Map<String, dynamic> documento) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          _getDocumentoIcon(documento['tipo'] ?? ''),
          color: Color(AppConfig.currentTenant.primaryColor),
          size: 32,
        ),
        title: Text(
          documento['nome'] ?? 'Documento sem nome',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${(documento['tipo'] ?? '').toString().toUpperCase()}'),
            if (documento['data'] != null)
              Text('Data: ${documento['data']}'),
            if (documento['profissional'] != null)
              Text('Profissional: ${documento['profissional']}'),
            if (documento['tamanho'] != null)
              Text('Tamanho: ${documento['tamanho']}'),
            if (documento['status'] != null)
              Text('Status: ${documento['status']}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => _downloadDocumento(documento['id']),
          tooltip: 'Baixar',
        ),
        onTap: () => _downloadDocumento(documento['id']),
      ),
    );
  }

  IconData _getDocumentoIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'exame':
        return Icons.science;
      case 'receita':
        return Icons.receipt;
      case 'atestado':
        return Icons.assignment;
      case 'relatorio':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}
