import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/notificacoes_service.dart';

class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  final NotificacoesService _notificacoesService = NotificacoesService();
  bool _isLoading = true;
  List<dynamic> _notificacoes = [];
  String _filtroStatus = 'todas';

  final List<String> _statusOptions = [
    'todas',
    'lidas',
    'nao_lidas',
  ];

  @override
  void initState() {
    super.initState();
    _loadNotificacoes();
  }

  Future<void> _loadNotificacoes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _notificacoesService.listarNotificacoes(
        status: _filtroStatus == 'todas' ? null : _filtroStatus,
      );

      if (response.success && response.data != null) {
        setState(() {
          _notificacoes = response.data!['notificacoes'] ?? [];
          _isLoading = false;
        });
      } else {
        _showErrorSnackBar(response.message);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao carregar notificações: $e');
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

  Future<void> _marcarComoLida(int notificacaoId) async {
    try {
      final response = await _notificacoesService.marcarComoLida(notificacaoId);
      if (response.success) {
        _loadNotificacoes(); // Recarregar lista
      } else {
        _showErrorSnackBar(response.message);
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao marcar notificação como lida: $e');
    }
  }

  void _showFiltros() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: DropdownButtonFormField<String>(
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadNotificacoes();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
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
            onPressed: _loadNotificacoes,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notificacoes.isEmpty
              ? const Center(
                  child: Text('Nenhuma notificação encontrada'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notificacoes.length,
                  itemBuilder: (context, index) {
                    return _buildNotificacaoCard(_notificacoes[index]);
                  },
                ),
    );
  }

  Widget _buildNotificacaoCard(Map<String, dynamic> notificacao) {
    final bool isLida = notificacao['lida'] ?? false;
    final String tipo = notificacao['tipo'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLida 
              ? Colors.grey[300] 
              : _getTipoColor(tipo),
          child: Icon(
            _getTipoIcon(tipo),
            color: isLida ? Colors.grey[600] : Colors.white,
          ),
        ),
        title: Text(
          notificacao['titulo'] ?? 'Sem título',
          style: TextStyle(
            fontWeight: isLida ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notificacao['mensagem'] ?? '',
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
                  _formatDate(notificacao['data'] ?? ''),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  _getTipoIcon(tipo),
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  _getTipoLabel(tipo),
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
            ? const Icon(Icons.check_circle, color: Colors.grey)
            : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => _marcarComoLida(notificacao['id']),
                tooltip: 'Marcar como lida',
              ),
        onTap: () {
          if (!isLida) {
            _marcarComoLida(notificacao['id']);
          }
          _showDetalhesNotificacao(notificacao);
        },
      ),
    );
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'lembrete':
        return Icons.schedule;
      case 'agendamento':
        return Icons.event;
      case 'vacina':
        return Icons.vaccines;
      case 'exame':
        return Icons.science;
      case 'pagamento':
        return Icons.payment;
      case 'sistema':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  Color _getTipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'lembrete':
        return Colors.blue;
      case 'agendamento':
        return Colors.green;
      case 'vacina':
        return Colors.orange;
      case 'exame':
        return Colors.purple;
      case 'pagamento':
        return Colors.red;
      case 'sistema':
        return Colors.grey;
      default:
        return Color(AppConfig.currentTenant.primaryColor);
    }
  }

  String _getTipoLabel(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'lembrete':
        return 'Lembrete';
      case 'agendamento':
        return 'Agendamento';
      case 'vacina':
        return 'Vacina';
      case 'exame':
        return 'Exame';
      case 'pagamento':
        return 'Pagamento';
      case 'sistema':
        return 'Sistema';
      default:
        return 'Notificação';
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

  void _showDetalhesNotificacao(Map<String, dynamic> notificacao) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notificacao['titulo'] ?? 'Sem título'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                notificacao['mensagem'] ?? '',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Data: ${_formatDate(notificacao['data'] ?? '')}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(_getTipoIcon(notificacao['tipo'] ?? ''), size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Tipo: ${_getTipoLabel(notificacao['tipo'] ?? '')}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              if (notificacao['acao'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.touch_app, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Ação: ${notificacao['acao']['tipo'] ?? ''}',
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
