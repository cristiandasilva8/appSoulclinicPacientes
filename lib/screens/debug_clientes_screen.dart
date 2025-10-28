import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../services/cliente_service.dart';
import '../models/api_response.dart';

class DebugClientesScreen extends StatefulWidget {
  const DebugClientesScreen({super.key});

  @override
  State<DebugClientesScreen> createState() => _DebugClientesScreenState();
}

class _DebugClientesScreenState extends State<DebugClientesScreen> {
  final AuthService _authService = AuthService();
  List<ClienteInfo> _clientes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _authService.buscarClientesDisponiveis();
      if (response.success && response.data != null) {
        setState(() {
          _clientes = response.data!;
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
        _error = 'Erro ao carregar clientes: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug - Clientes'),
        backgroundColor: Color(AppConfig.currentTenant.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClientes,
          ),
        ],
      ),
      body: Column(
        children: [
          // Informações do ambiente
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppConfig.isDebug ? Colors.orange[50] : Colors.green[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      AppConfig.isDebug ? Icons.bug_report : Icons.check_circle,
                      color: AppConfig.isDebug ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ambiente: ${AppConfig.environmentInfo}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppConfig.isDebug ? Colors.orange[700] : Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'URL: ${AppConfig.currentBaseUrl}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total de clientes: ${_clientes.length}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          
          // Lista de clientes
          Expanded(
            child: _buildClientesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClientesList() {
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
              onPressed: _loadClientes,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_clientes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum cliente encontrado',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _clientes.length,
      itemBuilder: (context, index) {
        final cliente = _clientes[index];
        return _buildClienteCard(cliente);
      },
    );
  }

  Widget _buildClienteCard(ClienteInfo cliente) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    cliente.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cliente.isAtivo ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cliente.isAtivo ? 'ATIVO' : 'INATIVO',
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
            Text(
              'CPF: ${cliente.cpf}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Email: ${cliente.email}',
              style: const TextStyle(fontSize: 14),
            ),
            if (cliente.telefone != null)
              Text(
                'Telefone: ${cliente.telefone}',
                style: const TextStyle(fontSize: 14),
              ),
            if (cliente.celular != null)
              Text(
                'Celular: ${cliente.celular}',
                style: const TextStyle(fontSize: 14),
              ),
            if (cliente.dbGroup != null)
              Text(
                'DB Group: ${cliente.dbGroup}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copiarCpf(cliente.cpf),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copiar CPF'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _usarCliente(cliente),
                    icon: const Icon(Icons.login, size: 16),
                    label: const Text('Usar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppConfig.currentTenant.primaryColor),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copiarCpf(String cpf) {
    // Em um app real, você usaria Clipboard.setData
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CPF copiado: $cpf'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _usarCliente(ClienteInfo cliente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usar Cliente'),
        content: Text('Deseja usar o cliente "${cliente.displayName}" para login?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Aqui você pode navegar de volta para a tela de login
              // e preencher automaticamente o CPF
              Navigator.pop(context, cliente.cpf);
            },
            child: const Text('Usar'),
          ),
        ],
      ),
    );
  }
}
