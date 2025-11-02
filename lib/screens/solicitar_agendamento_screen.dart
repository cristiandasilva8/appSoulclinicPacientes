import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../services/agendamentos_service.dart';

class SolicitarAgendamentoScreen extends StatefulWidget {
  const SolicitarAgendamentoScreen({super.key});

  @override
  State<SolicitarAgendamentoScreen> createState() => _SolicitarAgendamentoScreenState();
}

class _SolicitarAgendamentoScreenState extends State<SolicitarAgendamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final AgendamentosService _agendamentosService = AgendamentosService();
  
  final _tipoController = TextEditingController();
  final _especialidadeIdController = TextEditingController();
  final _profissionalIdController = TextEditingController();
  final _unidadeIdController = TextEditingController();
  final _observacoesController = TextEditingController();
  
  DateTime? _dataPreferencia;
  TimeOfDay? _horaPreferencia;
  bool _isLoading = false;

  @override
  void dispose() {
    _tipoController.dispose();
    _especialidadeIdController.dispose();
    _profissionalIdController.dispose();
    _unidadeIdController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _dataPreferencia) {
      setState(() {
        _dataPreferencia = picked;
      });
    }
  }

  Future<void> _selecionarHora() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaPreferencia ?? TimeOfDay.now(),
    );
    
    if (picked != null && picked != _horaPreferencia) {
      setState(() {
        _horaPreferencia = picked;
      });
    }
  }

  Future<void> _enviarSolicitacao() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dataPreferencia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma data de preferência'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_horaPreferencia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um horário de preferência'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dataFormatada = DateFormat('yyyy-MM-dd').format(_dataPreferencia!);
      final horaFormatada = '${_horaPreferencia!.hour.toString().padLeft(2, '0')}:${_horaPreferencia!.minute.toString().padLeft(2, '0')}';

      final response = await _agendamentosService.solicitarAgendamento(
        tipo: _tipoController.text.trim(),
        especialidadeId: int.tryParse(_especialidadeIdController.text) ?? 0,
        profissionalId: int.tryParse(_profissionalIdController.text) ?? 0,
        unidadeId: int.tryParse(_unidadeIdController.text) ?? 0,
        dataPreferencia: dataFormatada,
        horaPreferencia: horaFormatada,
        observacoes: _observacoesController.text.trim().isEmpty 
            ? null 
            : _observacoesController.text.trim(),
      );

      if (!mounted) return;

      if (response.success) {
        final protocolo = response.data?['protocolo'] ?? 'N/A';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Solicitação enviada com sucesso! Protocolo: $protocolo'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );

        Navigator.of(context).pop(true); // Retorna true para indicar sucesso
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erro ao enviar solicitação'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar solicitação: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Agendamento'),
        backgroundColor: Color(AppConfig.currentTenant.primaryColor),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tipo de agendamento
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Agendamento *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event_note),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'consulta', child: Text('Consulta')),
                        DropdownMenuItem(value: 'vacina', child: Text('Vacina')),
                        DropdownMenuItem(value: 'exame', child: Text('Exame')),
                        DropdownMenuItem(value: 'retorno', child: Text('Retorno')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _tipoController.text = value;
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione o tipo de agendamento';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Especialidade ID
                    TextFormField(
                      controller: _especialidadeIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID da Especialidade *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                        helperText: 'Informe o ID da especialidade desejada',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Informe um número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Profissional ID
                    TextFormField(
                      controller: _profissionalIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID do Profissional *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                        helperText: 'Informe o ID do profissional desejado',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Informe um número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Unidade ID
                    TextFormField(
                      controller: _unidadeIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID da Unidade *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                        helperText: 'Informe o ID da unidade desejada',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Informe um número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Data de preferência
                    InkWell(
                      onTap: _selecionarData,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data de Preferência *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _dataPreferencia == null
                              ? 'Selecione uma data'
                              : DateFormat('dd/MM/yyyy', 'pt_BR').format(_dataPreferencia!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hora de preferência
                    InkWell(
                      onTap: _selecionarHora,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Horário de Preferência *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _horaPreferencia == null
                              ? 'Selecione um horário'
                              : _horaPreferencia!.format(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Observações
                    TextFormField(
                      controller: _observacoesController,
                      decoration: const InputDecoration(
                        labelText: 'Observações (opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                        helperText: 'Informações adicionais sobre o agendamento',
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 24),

                    // Botão de enviar
                    ElevatedButton(
                      onPressed: _isLoading ? null : _enviarSolicitacao,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppConfig.currentTenant.primaryColor),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Enviar Solicitação',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

