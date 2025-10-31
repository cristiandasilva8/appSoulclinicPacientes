import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../utils/cpf_formatter.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cpfController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _cpfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esqueci minha senha'),
        backgroundColor: Color(AppConfig.currentTenant.primaryColor),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Informações de debug
              if (AppConfig.isDebug) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bug_report,
                            size: 16,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'DEBUG - ${AppConfig.environmentInfo}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppConfig.currentBaseUrl,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Ícone e título
              Icon(
                Icons.lock_reset,
                size: 80,
                color: Color(AppConfig.currentTenant.primaryColor),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Reset de Senha',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Color(AppConfig.currentTenant.primaryColor),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              Text(
                'Digite seu CPF para solicitar uma nova senha por email',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Campo CPF
              TextFormField(
                controller: _cpfController,
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CpfFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'CPF',
                  hintText: '000.000.000-00',
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                  suffixIcon: null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu CPF';
                  }
                  if (!CpfFormatter.isValidLength(value)) {
                    return 'CPF deve ter 11 dígitos';
                  }
                  if (!CpfFormatter.isValid(value)) {
                    return 'CPF inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Botão principal
              ElevatedButton(
                onPressed: _isLoading ? null : _pedirNovaSenha,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(AppConfig.currentTenant.primaryColor),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Pedir Nova Senha'),
              ),

              const SizedBox(height: 20),

              // Link para voltar ao login
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar ao Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pedirNovaSenha() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.resetPassword(
        cpf: CpfFormatter.removeMask(_cpfController.text.trim()),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.success && response.data != null) {
        if (response.data!.emailEnviado) {
          _showSuccessDialog(response.data!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao enviar email: ${response.data!.emailErro ?? 'Erro desconhecido'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog(ResetPasswordResponse data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Sucesso!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nova senha gerada e enviada com sucesso!'),
            const SizedBox(height: 16),
            if (data.pacienteEmail != null) ...[
              Text('Email enviado para: ${data.pacienteEmail}'),
              const SizedBox(height: 8),
            ],
            if (data.pacienteNome != null) ...[
              Text('Paciente: ${data.pacienteNome}'),
              const SizedBox(height: 8),
            ],
            const Text(
              'Verifique sua caixa de entrada e spam. A nova senha foi enviada por email.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fechar dialog
              Navigator.of(context).pop(); // Voltar para login
            },
            child: const Text('Voltar ao Login'),
          ),
        ],
      ),
    );
  }
}
