import 'package:flutter/material.dart';
import '../services/debug_service.dart';
import '../services/api_service.dart';

class DebugApiScreen extends StatefulWidget {
  const DebugApiScreen({super.key});

  @override
  State<DebugApiScreen> createState() => _DebugApiScreenState();
}

class _DebugApiScreenState extends State<DebugApiScreen> {
  final DebugService _debugService = DebugService();
  final ApiService _apiService = ApiService();
  final TextEditingController _pacienteIdController = TextEditingController(text: '10');
  String _logs = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarLogs();
  }

  void _carregarLogs() {
    setState(() {
      _logs = 'Debug API - Portal do Paciente\n';
      _logs += '================================\n\n';
    });
  }

  void _adicionarLog(String mensagem) {
    setState(() {
      _logs += '${DateTime.now().toString().substring(11, 19)} - $mensagem\n';
    });
  }

  Future<void> _testarToken() async {
    setState(() => _isLoading = true);
    _adicionarLog('🔍 Testando token...');
    
    try {
      await _debugService.testarTokenEnviado();
      _adicionarLog('✅ Teste de token concluído');
    } catch (e) {
      _adicionarLog('❌ Erro no teste de token: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testarAtualizacaoPaciente() async {
    setState(() => _isLoading = true);
    final pacienteId = int.tryParse(_pacienteIdController.text) ?? 10;
    _adicionarLog('🔍 Testando atualização do paciente ID: $pacienteId');
    
    try {
      await _debugService.testarAtualizacaoPaciente(pacienteId);
      _adicionarLog('✅ Teste de atualização concluído');
    } catch (e) {
      _adicionarLog('❌ Erro no teste de atualização: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verificarInterceptor() async {
    setState(() => _isLoading = true);
    _adicionarLog('🔍 Verificando interceptor...');
    
    try {
      await _debugService.verificarInterceptor();
      _adicionarLog('✅ Verificação do interceptor concluída');
    } catch (e) {
      _adicionarLog('❌ Erro na verificação do interceptor: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verificarToken() async {
    setState(() => _isLoading = true);
    _adicionarLog('🔍 Verificando token armazenado...');
    
    try {
      final token = await _apiService.getToken();
      if (token != null) {
        _adicionarLog('✅ Token encontrado: ${token.substring(0, 20)}...');
        _adicionarLog('📏 Tamanho do token: ${token.length} caracteres');
      } else {
        _adicionarLog('❌ Token não encontrado no SharedPreferences');
      }
    } catch (e) {
      _adicionarLog('❌ Erro ao verificar token: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _limparToken() async {
    setState(() => _isLoading = true);
    _adicionarLog('🗑️ Limpando tokens...');
    
    try {
      await _apiService.clearTokens();
      _adicionarLog('✅ Tokens limpos com sucesso');
    } catch (e) {
      _adicionarLog('❌ Erro ao limpar tokens: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug API'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _carregarLogs,
            icon: const Icon(Icons.refresh),
            tooltip: 'Limpar logs',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Controles
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Testes de API',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Campo ID do Paciente
                    TextField(
                      controller: _pacienteIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID do Paciente',
                        border: OutlineInputBorder(),
                        hintText: '10',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    
                    // Botões de teste
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _verificarToken,
                          icon: const Icon(Icons.key, size: 16),
                          label: const Text('Verificar Token'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _testarToken,
                          icon: const Icon(Icons.api, size: 16),
                          label: const Text('Testar Token'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _testarAtualizacaoPaciente,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Testar PUT'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _verificarInterceptor,
                          icon: const Icon(Icons.settings, size: 16),
                          label: const Text('Interceptor'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _limparToken,
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Limpar Token'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Logs
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Logs de Debug',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (_isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _logs,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pacienteIdController.dispose();
    super.dispose();
  }
}
