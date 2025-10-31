# Portal do Paciente - App Flutter

App móvel completo para pacientes com suporte a multitenancy, desenvolvido em Flutter.

## 🚀 Funcionalidades Implementadas

### ✅ Autenticação e Segurança
- Login com CPF e senha
- Autenticação JWT
- Reset de senha por email
- Alteração de senha
- Logout seguro

### ✅ Dashboard Completo
- Cards de acesso rápido para todas as funcionalidades
- Estatísticas em tempo real
- Próximos agendamentos
- Notificações recentes
- Informações do ambiente (debug/produção)

### ✅ Agendamentos
- Listagem de agendamentos
- Filtros por status, data e tipo
- Detalhes do agendamento
- Cancelamento com motivo
- Solicitação de novos agendamentos

### ✅ Carteira de Vacinação
- Listagem completa de vacinas
- Status das vacinas (aplicada, pendente, atrasada)
- Detalhes de cada vacina
- Documentos anexos
- Geração de PDF da carteira
- Estatísticas de vacinação

### ✅ Documentos
- Listagem de documentos médicos
- Filtros por tipo e data
- Download de documentos
- Suporte a PDFs, exames, receitas, atestados

### ✅ Mensagens
- Listagem de mensagens do sistema e profissionais
- Filtros por status e tipo
- Marcar como lida
- Detalhes da mensagem
- Prioridades (normal, alta)

### ✅ Notificações
- Listagem de notificações
- Filtros por status
- Marcar como lida
- Tipos: lembretes, agendamentos, vacinas, exames, pagamentos
- Configurações de notificação

### ✅ Contas a Pagar
- Listagem de contas
- Filtros por status e data
- Estatísticas financeiras
- Geração de cobrança (boleto e PIX)
- QR Code para pagamento PIX

### ✅ Perfil do Paciente
- Visualização de dados pessoais
- Edição de informações
- Upload de foto
- Preferências de contato

### ✅ Configurações
- Alteração de senha
- Configurações de notificação
- Configurações de privacidade
- Informações de segurança
- Logout

## 🏗️ Arquitetura

### Estrutura do Projeto
```
lib/
├── config/           # Configurações da aplicação
├── models/           # Modelos de dados
├── services/         # Serviços de API
├── screens/          # Telas da aplicação
├── utils/            # Utilitários
└── widgets/          # Widgets reutilizáveis
```

### Serviços Implementados
- `AuthService` - Autenticação e login
- `DashboardService` - Dados do dashboard
- `AgendamentosService` - Gestão de agendamentos
- `CarteiraVacinacaoService` - Carteira de vacinação
- `DocumentosService` - Gestão de documentos
- `MensagensService` - Sistema de mensagens
- `NotificacoesService` - Notificações
- `ContasPagarService` - Contas a pagar
- `ConfiguracoesService` - Configurações
- `PerfilService` - Perfil do paciente

### Modelos de Dados
- `User` - Dados do paciente
- `Agendamento` - Agendamentos
- `Vacina` - Vacinas e carteira
- `ApiResponse` - Respostas da API
- `Estatisticas` - Estatísticas do dashboard

## 🔧 Configuração

### 1. Instalar Dependências
```bash
flutter pub get
```

### 2. Configurar Ambiente
O app detecta automaticamente o ambiente:
- **Debug**: `http://127.0.0.1:8080/api/portal`
- **Produção**: `https://production.soulclinic.com.br/api/portal`

### 3. Executar o Aplicativo
```bash
flutter run
```

## 📱 Navegação

### Bottom Navigation Bar
- **Dashboard** - Tela principal com cards de acesso
- **Agendamentos** - Gestão de consultas
- **Vacinas** - Carteira de vacinação
- **Mensagens** - Sistema de mensagens
- **Perfil** - Dados pessoais

### Cards de Acesso Rápido
- Agendamentos
- Carteira de Vacinação
- Documentos
- Mensagens
- Notificações
- Contas a Pagar
- Perfil
- Configurações

## 🔌 Integração com API

### Endpoints Utilizados
- **Autenticação**: `/auth/login`, `/auth/forgot-password`, `/auth/change-password`
- **Dashboard**: `/dashboard`
- **Agendamentos**: `/agendamentos`
- **Vacinas**: `/carteira-vacinacao`
- **Documentos**: `/documentos`
- **Mensagens**: `/mensagens`
- **Notificações**: `/notificacoes`
- **Contas**: `/contas-pagar`
- **Configurações**: `/configuracoes`
- **Perfil**: `/perfil`

### Autenticação JWT
- Token de acesso (7 dias)
- Refresh token (30 dias)
- Headers automáticos
- Renovação automática

## 🎨 Design

### Material Design 3
- Tema personalizado por tenant
- Cores dinâmicas baseadas na clínica
- Cards com elevação
- Ícones intuitivos
- Navegação fluida

### Responsividade
- Layout adaptável
- Grid responsivo
- Scroll otimizado
- Feedback visual

## 🚀 Funcionalidades Avançadas

### Multitenancy
- Detecção automática de tenant
- Configurações por clínica
- URLs dinâmicas
- Temas personalizados

### Debug e Desenvolvimento
- Banner de ambiente
- Logs detalhados
- Tela de debug de clientes
- Tela de debug de API

### Validações
- CPF com máscara e validação
- Validação de formulários
- Mensagens de erro claras
- Feedback visual

## 📋 Status da Implementação

- ✅ **100%** - Autenticação e segurança
- ✅ **100%** - Dashboard e navegação
- ✅ **100%** - Agendamentos
- ✅ **100%** - Carteira de vacinação
- ✅ **100%** - Documentos
- ✅ **100%** - Mensagens
- ✅ **100%** - Notificações
- ✅ **100%** - Contas a pagar
- ✅ **100%** - Perfil e configurações

## 🔧 Desenvolvimento

### Dependências Principais
- `flutter_bloc` - Gerenciamento de estado
- `dio` - Cliente HTTP
- `shared_preferences` - Armazenamento local
- `url_launcher` - Abertura de URLs
- `intl` - Formatação de datas

### Comandos Úteis
```bash
# Executar em modo debug
flutter run --debug

# Ver logs
flutter logs

# Limpar cache
flutter clean && flutter pub get

# Análise de código
flutter analyze
```

## 📞 Suporte

Para dúvidas ou problemas:
- Verificar logs do Flutter
- Testar conectividade com a API
- Validar configurações de ambiente
- Consultar documentação da API

## 👨‍💻 Desenvolvedor

**Cristian da Silva**
- Email: cristian@example.com
- Documentação: `docs/API_PORTAL_PACIENTE.md`

---

*Desenvolvido com Flutter para o Portal do Paciente*