import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/mensagens_service.dart';

class MensagensScreen extends StatefulWidget {
  const MensagensScreen({super.key});

  @override
  State<MensagensScreen> createState() => _MensagensScreenState();
}

class _MensagensScreenState extends State<MensagensScreen> {
  final MensagensService _mensagensService = MensagensService();
  bool _isLoading = true;
  List<dynamic> _mensagens = [];
  String _filtroStatus = 'todas';
  String _filtroTipo = 'todas';

  final List<String> _statusOptions = [
    'todas',
    'lidas',
    'nao_lidas',
  ];

  final List<String> _tipoOptions = [
    'todas',
    'sistema',
    'profissional',
  ];

  @override
  void initState() {
    super.initState();
    _loadMensagens();
  }

  Future<void> _loadMensagens() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _mensagensService.listarMensagens(
        status: _filtroStatus == 'todas' ? null : _filtroStatus,
        tipo: _filtroTipo == 'todas' ? null : _filtroTipo,
      );

      if (response.success && response.data != null) {
        setState(() {
          _mensagens = response.data!['mensagens'] ?? [];
          _isLoading = false;
        });
      } else {
        _showErrorSnackBar(response.message);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao carregar mensagens: $e');
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

  Future<void> _marcarComoLida(int mensagemId) async {
    try {
      final response = await _mensagensService.marcarComoLida(mensagemId);
      if (response.success) {
        _loadMensagens(); // Recarregar lista
      } else {
        _showErrorSnackBar(response.message);
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao marcar mensagem como lida: $e');
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
            DropdownButtonFormField<String>(
              value: _filtroTipo,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
              ),
              items: _tipoOptions.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(_getTipoLabel(tipo)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _filtroTipo = value ?? 'todas';
                });
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
              _loadMensagens();
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
      case 'lidas':
        return 'Lidas';
      case 'nao_lidas':
        return 'Não Lidas';
      default:
        return status;
    }
  }

  String _getTipoLabel(String tipo) {
    switch (tipo) {
      case 'todas':
        return 'Todas';
      case 'sistema':
        return 'Sistema';
      case 'profissional':
        return 'Profissional';
      default:
        return tipo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagens'),
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
            onPressed: _loadMensagens,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mensagens.isEmpty
              ? const Center(
                  child: Text('Nenhuma mensagem encontrada'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _mensagens.length,
                  itemBuilder: (context, index) {
                    return _buildMensagemCard(_mensagens[index]);
                  },
                ),
    );
  }

  Widget _buildMensagemCard(Map<String, dynamic> mensagem) {
    final bool isLida = mensagem['lida'] ?? false;
    final String prioridade = mensagem['prioridade'] ?? 'normal';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLida 
              ? Colors.grey[300] 
              : Color(AppConfig.currentTenant.primaryColor),
          child: Icon(
            _getMensagemIcon(mensagem['tipo'] ?? ''),
            color: isLida ? Colors.grey[600] : Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                mensagem['titulo'] ?? 'Sem título',
                style: TextStyle(
                  fontWeight: isLida ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
            if (prioridade == 'alta')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'ALTA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mensagem['mensagem'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isLida ? Colors.grey[600] : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(mensagem['data'] ?? ''),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.person,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  _getTipoLabel(mensagem['tipo'] ?? ''),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: isLida
            ? const Icon(Icons.mark_email_read, color: Colors.grey)
            : IconButton(
                icon: const Icon(Icons.mark_email_unread),
                onPressed: () => _marcarComoLida(mensagem['id']),
                tooltip: 'Marcar como lida',
              ),
        onTap: () {
          if (!isLida) {
            _marcarComoLida(mensagem['id']);
          }
          _showDetalhesMensagem(mensagem);
        },
      ),
    );
  }

  IconData _getMensagemIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'sistema':
        return Icons.settings;
      case 'profissional':
        return Icons.person;
      default:
        return Icons.message;
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

  void _showDetalhesMensagem(Map<String, dynamic> mensagem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(mensagem['titulo'] ?? 'Sem título'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mensagem['mensagem'] ?? '',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Data: ${_formatDate(mensagem['data'] ?? '')}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Tipo: ${_getTipoLabel(mensagem['tipo'] ?? '')}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              if (mensagem['prioridade'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.priority_high, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Prioridade: ${mensagem['prioridade'].toString().toUpperCase()}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
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
}
