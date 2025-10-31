import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/configuracoes_service.dart';
import '../services/auth_service.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  final ConfiguracoesService _configuracoesService = ConfiguracoesService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  Map<String, dynamic>? _configuracoes;

  // Controllers para alteração de senha
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadConfiguracoes();
  }

  @override
  void dispose() {
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _loadConfiguracoes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _configuracoesService.buscarConfiguracoes();
      if (response.success && response.data != null) {
        setState(() {
          _configuracoes = response.data!;
          _isLoading = false;
        });
      } else {
        _showErrorSnackBar(response.message);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao carregar configurações: $e');
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAlterarSenhaDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Senha'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _senhaAtualController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha Atual',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Senha atual é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _novaSenhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nova Senha',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nova senha é obrigatória';
                  }
                  if (value.length < 8) {
                    return 'A senha deve ter pelo menos 8 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmarSenhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Nova Senha',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirmação de senha é obrigatória';
                  }
                  if (value != _novaSenhaController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _senhaAtualController.clear();
              _novaSenhaController.clear();
              _confirmarSenhaController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _alterarSenha,
            child: const Text('Alterar'),
          ),
        ],
      ),
    );
  }

  Future<void> _alterarSenha() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await _configuracoesService.alterarSenha(
        senhaAtual: _senhaAtualController.text,
        novaSenha: _novaSenhaController.text,
        confirmarSenha: _confirmarSenhaController.text,
      );

      if (response.success) {
        _senhaAtualController.clear();
        _novaSenhaController.clear();
        _confirmarSenhaController.clear();
        Navigator.pop(context);
        _showSuccessSnackBar('Senha alterada com sucesso!');
      } else {
        _showErrorSnackBar(response.message);
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao alterar senha: $e');
    }
  }

  Future<void> _atualizarNotificacoes(Map<String, dynamic> notificacoes) async {
    try {
      final response = await _configuracoesService.atualizarNotificacoes(
        email: notificacoes['email'] ?? false,
        sms: notificacoes['sms'] ?? false,
        push: notificacoes['push'] ?? false,
        lembretesAgendamento: notificacoes['lembretes_agendamento'] ?? false,
        lembretesVacina: notificacoes['lembretes_vacina'] ?? false,
        novidades: notificacoes['novidades'] ?? false,
      );

      if (response.success) {
        _showSuccessSnackBar('Configurações atualizadas com sucesso!');
        _loadConfiguracoes();
      } else {
        _showErrorSnackBar(response.message);
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao atualizar configurações: $e');
    }
  }

  void _showNotificacoesDialog() {
    final notificacoes = _configuracoes?['notificacoes'] ?? {};
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Configurações de Notificação'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Email'),
                  subtitle: const Text('Receber notificações por email'),
                  value: notificacoes['email'] ?? false,
                  onChanged: (value) {
                    setState(() {
                      notificacoes['email'] = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('SMS'),
                  subtitle: const Text('Receber notificações por SMS'),
                  value: notificacoes['sms'] ?? false,
                  onChanged: (value) {
                    setState(() {
                      notificacoes['sms'] = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Push'),
                  subtitle: const Text('Receber notificações push'),
                  value: notificacoes['push'] ?? false,
                  onChanged: (value) {
                    setState(() {
                      notificacoes['push'] = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Lembretes de Agendamento'),
                  subtitle: const Text('Receber lembretes de consultas'),
                  value: notificacoes['lembretes_agendamento'] ?? false,
                  onChanged: (value) {
                    setState(() {
                      notificacoes['lembretes_agendamento'] = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Lembretes de Vacina'),
                  subtitle: const Text('Receber lembretes de vacinas'),
                  value: notificacoes['lembretes_vacina'] ?? false,
                  onChanged: (value) {
                    setState(() {
                      notificacoes['lembretes_vacina'] = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Novidades'),
                  subtitle: const Text('Receber novidades e promoções'),
                  value: notificacoes['novidades'] ?? false,
                  onChanged: (value) {
                    setState(() {
                      notificacoes['novidades'] = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _atualizarNotificacoes(notificacoes);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Logout'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Implementar logout
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Color(AppConfig.currentTenant.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConfiguracoes,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _configuracoes == null
              ? const Center(
                  child: Text('Erro ao carregar configurações'),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Seção de Segurança
                    _buildSectionCard(
                      'Segurança',
                      Icons.security,
                      [
                        ListTile(
                          leading: const Icon(Icons.lock),
                          title: const Text('Alterar Senha'),
                          subtitle: const Text('Alterar sua senha de acesso'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _showAlterarSenhaDialog,
                        ),
                        if (_configuracoes?['seguranca'] != null) ...[
                          ListTile(
                            leading: const Icon(Icons.security),
                            title: const Text('Autenticação de 2 Fatores'),
                            subtitle: Text(
                              _configuracoes!['seguranca']['autenticacao_2fatores'] == true
                                  ? 'Ativada'
                                  : 'Desativada',
                            ),
                            trailing: Switch(
                              value: _configuracoes!['seguranca']['autenticacao_2fatores'] ?? false,
                              onChanged: (value) {
                                // Implementar ativação/desativação de 2FA
                                _showErrorSnackBar('Funcionalidade em desenvolvimento');
                              },
                            ),
                          ),
                          if (_configuracoes!['seguranca']['ultimo_login'] != null)
                            ListTile(
                              leading: const Icon(Icons.access_time),
                              title: const Text('Último Login'),
                              subtitle: Text(
                                _formatDate(_configuracoes!['seguranca']['ultimo_login']),
                              ),
                            ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Seção de Notificações
                    _buildSectionCard(
                      'Notificações',
                      Icons.notifications,
                      [
                        ListTile(
                          leading: const Icon(Icons.settings),
                          title: const Text('Configurações de Notificação'),
                          subtitle: const Text('Gerenciar preferências de notificação'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _showNotificacoesDialog,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Seção de Privacidade
                    if (_configuracoes?['privacidade'] != null)
                      _buildSectionCard(
                        'Privacidade',
                        Icons.privacy_tip,
                        [
                          ListTile(
                            leading: const Icon(Icons.share),
                            title: const Text('Compartilhar Dados'),
                            subtitle: const Text('Permitir compartilhamento de dados'),
                            trailing: Switch(
                              value: _configuracoes!['privacidade']['compartilhar_dados'] ?? false,
                              onChanged: (value) {
                                // Implementar alteração de privacidade
                                _showErrorSnackBar('Funcionalidade em desenvolvimento');
                              },
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.campaign),
                            title: const Text('Receber Marketing'),
                            subtitle: const Text('Receber comunicações de marketing'),
                            trailing: Switch(
                              value: _configuracoes!['privacidade']['receber_marketing'] ?? false,
                              onChanged: (value) {
                                // Implementar alteração de marketing
                                _showErrorSnackBar('Funcionalidade em desenvolvimento');
                              },
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Seção de Conta
                    _buildSectionCard(
                      'Conta',
                      Icons.account_circle,
                      [
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text('Sair da Conta', style: TextStyle(color: Colors.red)),
                          subtitle: const Text('Fazer logout da sua conta'),
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Color(AppConfig.currentTenant.primaryColor)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
