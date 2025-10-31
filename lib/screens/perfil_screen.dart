import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../config/app_config.dart';
import '../services/auth_bloc.dart';
import '../services/dashboard_service.dart';
import '../services/perfil_service.dart';
import '../services/configuracoes_service.dart';
import '../models/user.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final PerfilService _perfilService = PerfilService();
  final ConfiguracoesService _configuracoesService = ConfiguracoesService();
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _celularController = TextEditingController();
  
  User? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  String? _error;
  bool _temPedidoExclusao = false;

  @override
  void initState() {
    super.initState();
    _loadPerfil();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _celularController.dispose();
    super.dispose();
  }

  Future<void> _loadPerfil() async {
    print('🔍 Iniciando carregamento do perfil...');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('📡 Fazendo requisição ao serviço de perfil...');
      final response = await _perfilService.getPerfil();
      print('📡 Resposta recebida: success=${response.success}, message=${response.message}');
      print('📡 Response.data é null? ${response.data == null}');
      
      if (response.success && response.data != null) {
        try {
          print('🔍 Dados do perfil recebidos: ${response.data}');
          print('🔍 Tipo de response.data: ${response.data.runtimeType}');
          print('🔍 response.data é User? ${response.data is User}');
          
          // Usar os dados diretamente do response.data (que já é um User)
          final user = response.data!;
          print('✅ User criado: id=${user.id}, nome=${user.nome}, email=${user.email}');
          
          // Verificar se existe pedido de exclusão
          await _verificarPedidoExclusao();
          
          setState(() {
            _user = user;
            _nomeController.text = user.nome;
            _telefoneController.text = user.telefone ?? '';
            _celularController.text = user.celular ?? '';
            _isLoading = false;
          });
          
          print('✅ Perfil carregado com sucesso');
        } catch (parseError, stackTrace) {
          print('❌ Erro ao processar dados do perfil: $parseError');
          print('❌ Stack trace: $stackTrace');
          setState(() {
            _error = 'Erro ao processar dados do perfil: ${parseError.toString()}';
            _isLoading = false;
          });
        }
      } else {
        print('❌ Resposta não foi bem-sucedida ou dados são null');
        print('❌ Success: ${response.success}');
        print('❌ Message: ${response.message}');
        print('❌ Errors: ${response.errors}');
        
        // Verificar se é erro de autenticação (token expirado)
        final errorMessage = response.message.toLowerCase();
        if (errorMessage.contains('token inválido') || 
            errorMessage.contains('token expirado') ||
            errorMessage.contains('401')) {
          // Token expirado - redirecionar para login
          if (mounted) {
            context.read<AuthBloc>().add(LogoutRequested());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sessão expirada. Por favor, faça login novamente.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
        
        setState(() {
          _error = response.message.isNotEmpty 
              ? response.message 
              : 'Erro ao carregar perfil. Verifique sua conexão.';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('💥 Erro geral ao carregar perfil: $e');
      print('💥 Stack trace: $stackTrace');
      
      // Verificar se é erro de autenticação (token expirado)
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('token inválido') || 
          errorMessage.contains('token expirado') ||
          errorMessage.contains('401')) {
        // Token expirado - redirecionar para login
        if (mounted) {
          context.read<AuthBloc>().add(LogoutRequested());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sessão expirada. Por favor, faça login novamente.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      setState(() {
        _error = 'Erro ao carregar perfil: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Color(AppConfig.currentTenant.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPerfil,
          ),
        ],
      ),
      body: _buildPerfilContent(),
    );
  }

  Widget _buildPerfilContent() {
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
              onPressed: _loadPerfil,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_user == null) {
      return const Center(child: Text('Usuário não encontrado'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Foto do perfil
            _buildFotoPerfil(),
            const SizedBox(height: 24),

            // Informações pessoais
            _buildInformacoesPessoais(),
            const SizedBox(height: 24),

            // Endereço
            if (_user!.endereco != null) _buildEndereco(),
            const SizedBox(height: 24),

            // Preferências
            if (_user!.preferencias != null) _buildPreferencias(),
            const SizedBox(height: 24),

            // Exclusão de conta
            _buildExclusaoConta(),
            const SizedBox(height: 24),

            // Botões de ação
            if (_isEditing) _buildBotoesAcao(),
          ],
        ),
      ),
    );
  }

  Widget _buildFotoPerfil() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Color(AppConfig.currentTenant.primaryColor),
            backgroundImage: _user!.fotoUrl != null
                ? NetworkImage(_user!.fotoUrl!)
                : null,
            child: _user!.fotoUrl == null
                ? Text(
                    _user!.nome.isNotEmpty ? _user!.nome[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(AppConfig.tenants['soulclinic']!.primaryColor),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: _selecionarFoto,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInformacoesPessoais() {
    return Card(
      elevation: AppConfig.elevation,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Pessoais',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomeController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu nome';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefoneController,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _celularController,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Celular',
                prefixIcon: Icon(Icons.phone_android),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _user!.email,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _user!.cpf,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'CPF',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _user!.dataNascimento,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Data de Nascimento',
                prefixIcon: Icon(Icons.cake),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndereco() {
    final endereco = _user!.endereco!;
    return Card(
      elevation: AppConfig.elevation,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Endereço',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: endereco.cep,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'CEP',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: endereco.logradouro,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Logradouro',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: endereco.numero,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Número',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: endereco.complemento ?? '',
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Complemento',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: endereco.bairro,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Bairro',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: endereco.cidade,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Cidade',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: endereco.estado,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
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

  Widget _buildPreferencias() {
    final preferencias = _user!.preferencias!;
    return Card(
      elevation: AppConfig.elevation,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferências de Notificação',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Notificações por Email'),
              subtitle: const Text('Receber notificações por email'),
              value: preferencias.notificacoesEmail,
              onChanged: _isEditing ? (value) {
                setState(() {
                  _user = _user!.copyWith(
                    preferencias: preferencias.copyWith(
                      notificacoesEmail: value,
                    ),
                  );
                });
              } : null,
            ),
            SwitchListTile(
              title: const Text('Notificações por SMS'),
              subtitle: const Text('Receber notificações por SMS'),
              value: preferencias.notificacoesSms,
              onChanged: _isEditing ? (value) {
                setState(() {
                  _user = _user!.copyWith(
                    preferencias: preferencias.copyWith(
                      notificacoesSms: value,
                    ),
                  );
                });
              } : null,
            ),
            SwitchListTile(
              title: const Text('Notificações Push'),
              subtitle: const Text('Receber notificações push no app'),
              value: preferencias.notificacoesPush,
              onChanged: _isEditing ? (value) {
                setState(() {
                  _user = _user!.copyWith(
                    preferencias: preferencias.copyWith(
                      notificacoesPush: value,
                    ),
                  );
                });
              } : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verificarPedidoExclusao() async {
    try {
      final response = await _configuracoesService.buscarConfiguracoes();
      if (response.success && response.data != null) {
        // Verificar se existe campo de pedido de exclusão nos dados
        final data = response.data!;
        // Pode estar em diferentes formatos dependendo da implementação da API
        final temPedido = data['pedido_exclusao'] == true ||
                         data['solicitacao_exclusao'] == true ||
                         (data['metadata'] != null && 
                          data['metadata'] is Map && 
                          (data['metadata'] as Map)['pedido_exclusao'] == true);
        
        setState(() {
          _temPedidoExclusao = temPedido;
        });
      }
    } catch (e) {
      print('⚠️ Erro ao verificar pedido de exclusão: $e');
      // Em caso de erro, assumir que não há pedido
      setState(() {
        _temPedidoExclusao = false;
      });
    }
  }

  Future<void> _solicitarExclusaoConta() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirmar Exclusão'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tem certeza que deseja solicitar a exclusão da sua conta?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Esta ação irá:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('• Solicitar a exclusão permanente da sua conta'),
            Text('• Notificar a clínica sobre sua solicitação'),
            Text('• Todos os seus dados serão removidos'),
            SizedBox(height: 16),
            Text(
              'Esta ação não pode ser desfeita facilmente.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await _configuracoesService.solicitarExclusaoConta();

      if (mounted) {
        Navigator.pop(context); // Fechar loading

        if (response.success) {
          setState(() {
            _temPedidoExclusao = true;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solicitação de exclusão registrada com sucesso. A clínica será notificada.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fechar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao solicitar exclusão: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _retirarPedidoExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirar Pedido de Exclusão'),
        content: const Text(
          'Tem certeza que deseja retirar o pedido de exclusão da sua conta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await _configuracoesService.retirarPedidoExclusao();

      if (mounted) {
        Navigator.pop(context); // Fechar loading

        if (response.success) {
          setState(() {
            _temPedidoExclusao = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pedido de exclusão retirado com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fechar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao retirar pedido de exclusão: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildExclusaoConta() {
    return Card(
      elevation: AppConfig.elevation,
      color: _temPedidoExclusao ? Colors.orange[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _temPedidoExclusao ? Icons.pending_actions : Icons.delete_forever,
                  color: _temPedidoExclusao ? Colors.orange[700] : Colors.red[700],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Exclusão de Conta',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _temPedidoExclusao ? Colors.orange[700] : Colors.red[700],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_temPedidoExclusao)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[800], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Você possui um pedido de exclusão pendente. A clínica será notificada.',
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red[800], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Atenção: Esta ação é irreversível e todos os seus dados serão removidos permanentemente.',
                        style: TextStyle(
                          color: Colors.red[900],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Ao excluir sua conta, todos os seus dados serão removidos permanentemente. Esta ação não pode ser desfeita.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            if (_temPedidoExclusao)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _retirarPedidoExclusao,
                  icon: const Icon(Icons.cancel),
                  label: const Text('Retirar Pedido de Exclusão'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _solicitarExclusaoConta,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Solicitar Exclusão de Conta'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[700],
                    side: BorderSide(color: Colors.red[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotoesAcao() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _cancelarEdicao,
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _salvarPerfil,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConfig.currentTenant.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('Salvar'),
          ),
        ),
      ],
    );
  }

  void _selecionarFoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(context);
                _capturarFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _capturarFoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _capturarFoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source);
      
      if (image != null) {
        // TODO: Implementar upload da foto
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload de foto em desenvolvimento'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar foto: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _cancelarEdicao() {
    setState(() {
      _isEditing = false;
      _nomeController.text = _user!.nome;
      _telefoneController.text = _user!.telefone ?? '';
      _celularController.text = _user!.celular ?? '';
    });
  }

  Future<void> _salvarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await _perfilService.atualizarPerfil({
        'nome': _nomeController.text.trim(),
        'telefone': _telefoneController.text.trim().isEmpty 
            ? null 
            : _telefoneController.text.trim(),
        'celular': _celularController.text.trim().isEmpty 
            ? null 
            : _celularController.text.trim(),
        'preferencias': _user!.preferencias?.toJson(),
      });

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditing = false;
        });
        _loadPerfil();
      } else {
        // Verificar se é erro de autenticação (token expirado)
        final errorMessage = response.message.toLowerCase();
        if (errorMessage.contains('token inválido') || 
            errorMessage.contains('token expirado') ||
            errorMessage.contains('401')) {
          // Token expirado - redirecionar para login
          context.read<AuthBloc>().add(LogoutRequested());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sessão expirada. Por favor, faça login novamente.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Verificar se é erro de autenticação (token expirado)
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('token inválido') || 
          errorMessage.contains('token expirado') ||
          errorMessage.contains('401')) {
        // Token expirado - redirecionar para login
        if (mounted) {
          context.read<AuthBloc>().add(LogoutRequested());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sessão expirada. Por favor, faça login novamente.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar perfil: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
