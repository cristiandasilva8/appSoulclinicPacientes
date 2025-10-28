import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/dashboard_service.dart';
import '../models/agendamento.dart';

class AgendamentosScreen extends StatefulWidget {
  const AgendamentosScreen({super.key});

  @override
  State<AgendamentosScreen> createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen> {
  final AgendamentosService _agendamentosService = AgendamentosService();
  List<Agendamento> _agendamentos = [];
  bool _isLoading = true;
  String? _error;
  String _statusFilter = 'todos';

  @override
  void initState() {
    super.initState();
    _loadAgendamentos();
  }

  Future<void> _loadAgendamentos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _agendamentosService.getAgendamentos(
        status: _statusFilter == 'todos' ? null : _statusFilter,
      );
      
      if (response.success && response.data != null) {
        setState(() {
          _agendamentos = response.data!.agendamentos;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar agendamentos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        backgroundColor: Color(AppConfig.currentTenant.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAgendamentos,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _statusFilter,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Todos')),
                      DropdownMenuItem(value: 'confirmados', child: Text('Confirmados')),
                      DropdownMenuItem(value: 'pendentes', child: Text('Pendentes')),
                      DropdownMenuItem(value: 'cancelados', child: Text('Cancelados')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _statusFilter = value;
                        });
                        _loadAgendamentos();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implementar solicitação de agendamento
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Funcionalidade em desenvolvimento'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Solicitar'),
                ),
              ],
            ),
          ),
          
          // Lista de agendamentos
          Expanded(
            child: _buildAgendamentosList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendamentosList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAgendamentos,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_agendamentos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum agendamento encontrado',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAgendamentos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _agendamentos.length,
        itemBuilder: (context, index) {
          final agendamento = _agendamentos[index];
          return _buildAgendamentoCard(agendamento);
        },
      ),
    );
  }

  Widget _buildAgendamentoCard(Agendamento agendamento) {
    Color statusColor;
    switch (agendamento.status) {
      case 'confirmado':
        statusColor = Colors.green;
        break;
      case 'pendente':
        statusColor = Colors.orange;
        break;
      case 'cancelado':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: AppConfig.elevation,
      child: InkWell(
        onTap: () => _showAgendamentoDetails(agendamento),
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      agendamento.tipo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      agendamento.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('${agendamento.data} às ${agendamento.hora}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(child: Text(agendamento.profissional)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(child: Text(agendamento.unidade)),
                ],
              ),
              if (agendamento.sala != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.room, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Sala ${agendamento.sala}'),
                  ],
                ),
              ],
              if (agendamento.protocolo != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Protocolo: ${agendamento.protocolo}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              if (agendamento.status == 'confirmado' || agendamento.status == 'pendente') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _cancelarAgendamento(agendamento),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAgendamentoDetails(Agendamento agendamento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(agendamento.tipo),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Data', '${agendamento.data} às ${agendamento.hora}'),
              _buildDetailRow('Profissional', agendamento.profissional),
              _buildDetailRow('Unidade', agendamento.unidade),
              if (agendamento.sala != null)
                _buildDetailRow('Sala', agendamento.sala!),
              _buildDetailRow('Status', agendamento.status),
              if (agendamento.protocolo != null)
                _buildDetailRow('Protocolo', agendamento.protocolo!),
              if (agendamento.observacoes != null)
                _buildDetailRow('Observações', agendamento.observacoes!),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _cancelarAgendamento(Agendamento agendamento) {
    showDialog(
      context: context,
      builder: (context) {
        final motivoController = TextEditingController();
        return AlertDialog(
          title: const Text('Cancelar Agendamento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Deseja cancelar o agendamento de ${agendamento.tipo}?'),
              const SizedBox(height: 16),
              TextField(
                controller: motivoController,
                decoration: const InputDecoration(
                  labelText: 'Motivo do cancelamento',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _confirmarCancelamento(agendamento.id, motivoController.text);
              },
              child: const Text('Sim, Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmarCancelamento(int agendamentoId, String motivo) async {
    try {
      final response = await _agendamentosService.cancelarAgendamento(
        id: agendamentoId,
        motivo: motivo,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendamento cancelado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAgendamentos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cancelar agendamento: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
