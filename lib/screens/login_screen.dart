import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/app_config.dart';
import '../services/auth_bloc.dart';
import '../utils/cpf_formatter.dart';
import 'dashboard_screen.dart';
import 'debug_clientes_screen.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cpfController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _cpfController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          print('🔍 AuthBloc State: $state');
          print('🔍 State type: ${state.runtimeType}');
          
          if (state is AuthAuthenticated) {
            print('✅ Login bem-sucedido, navegando para dashboard');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          } else if (state is AuthError) {
            print('❌ Erro de autenticação: ${state.message}');
            print('❌ Tentando mostrar SnackBar...');
            
            // Forçar o SnackBar a aparecer
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('ERRO: ${state.message}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 10),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            });
          } else if (state is AuthLoading) {
            print('⏳ Carregando...');
          } else {
            print('🔄 Estado: $state');
          }
        },
        builder: (context, state) {
          // Mostrar mensagem de erro diretamente na tela
          if (state is AuthError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('ERRO: ${state.message}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 10),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            });
          }
          
          return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(AppConfig.currentTenant.primaryColor).withOpacity(0.8),
                Color(AppConfig.currentTenant.primaryColor),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConfig.defaultPadding),
                child: Card(
                  elevation: AppConfig.elevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Image.asset(
                            AppConfig.currentTenant.logoUrl,
                            height: 80,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.local_hospital,
                                size: 80,
                                color: Color(AppConfig.currentTenant.primaryColor),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Título
                          Text(
                            'Portal do Paciente',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Color(AppConfig.currentTenant.primaryColor),
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          Text(
                            AppConfig.currentTenant.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Informações de debug
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppConfig.isDebug ? Colors.orange[100] : Colors.green[100],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppConfig.isDebug ? Colors.orange : Colors.green,
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
                                      AppConfig.isDebug ? Icons.bug_report : Icons.check_circle,
                                      size: 16,
                                      color: AppConfig.isDebug ? Colors.orange[700] : Colors.green[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppConfig.environmentInfo,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppConfig.isDebug ? Colors.orange[700] : Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppConfig.currentBaseUrl,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppConfig.isDebug ? Colors.orange[600] : Colors.green[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Campo CPF
                          TextFormField(
                            controller: _cpfController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CpfFormatter(),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'CPF',
                              hintText: '000.000.000-00',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
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
                          const SizedBox(height: 16),

                          // Campo Senha
                          TextFormField(
                            controller: _senhaController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira sua senha';
                              }
                              if (value.length < 6) {
                                return 'A senha deve ter pelo menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Botão Login
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: state is AuthLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(AppConfig.currentTenant.primaryColor),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                                    ),
                                  ),
                                  child: state is AuthLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text(
                                          'Entrar',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Link Esqueci Senha
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ResetPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text('Esqueci minha senha'),
                          ),
                          
                          // Botão de debug (apenas em modo debug)
                          if (AppConfig.isDebug) ...[
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () async {
                                final cpf = await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DebugClientesScreen(),
                                  ),
                                );
                                if (cpf != null) {
                                  _cpfController.text = cpf;
                                }
                              },
                              icon: const Icon(Icons.bug_report, size: 16),
                              label: const Text('Debug - Ver Clientes'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange,
                                side: const BorderSide(color: Colors.orange),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        },
      ),
    );
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Detectar clínica automaticamente
      final currentTenant = AppConfig.detectTenantFromCrm();
      
      context.read<AuthBloc>().add(
        LoginRequested(
          cpf: _cpfController.text.trim(), // Enviar CPF com máscara
          senha: _senhaController.text,
          dbGroup: currentTenant,
        ),
      );
    }
  }
}
