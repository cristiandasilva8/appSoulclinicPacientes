# Portal do Paciente - App Flutter

App móvel para pacientes com suporte a multitenancy, desenvolvido em Flutter.

## 🚀 Funcionalidades

- **Autenticação JWT** com suporte a multitenancy
- **Dashboard** com estatísticas e próximos agendamentos
- **Agendamentos** - visualizar, cancelar e solicitar
- **Perfil do Paciente** - editar informações pessoais
- **Carteira de Vacinação** - histórico de vacinas
- **Documentos** - acesso a exames e receitas
- **Mensagens** - comunicação com profissionais
- **Notificações** - lembretes e alertas
- **Contas a Pagar** - visualizar e pagar faturas

## 🏗️ Arquitetura

- **Estado**: BLoC (flutter_bloc)
- **HTTP**: Dio
- **Armazenamento**: SharedPreferences
- **UI**: Material Design 3
- **Multitenancy**: Configuração por tenant

## 📱 Telas Principais

1. **Login** - Autenticação com seleção de tenant
2. **Dashboard** - Visão geral com estatísticas
3. **Agendamentos** - Lista e detalhes de agendamentos
4. **Perfil** - Informações pessoais e preferências

## 🔧 Configuração

### Dependências Principais

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  dio: ^5.3.2
  shared_preferences: ^2.2.2
  jwt_decoder: ^2.0.1
  image_picker: ^1.0.4
```

### Estrutura de Pastas

```
lib/
├── config/          # Configurações e multitenancy
├── models/           # Modelos de dados
├── services/         # Serviços de API e BLoC
├── screens/          # Telas da aplicação
├── widgets/          # Componentes reutilizáveis
└── utils/            # Utilitários
```

## 🌐 API

Baseado na documentação `API_PORTAL_PACIENTE.md`:

- **Base URL**: Configurável por tenant
- **Autenticação**: JWT Bearer Token
- **Formato**: JSON
- **Multitenancy**: Suporte completo

## 🚀 Como Executar

1. Instalar dependências:
```bash
flutter pub get
```

2. Executar o app:
```bash
flutter run
```

## 📋 TODO

- [ ] Implementar carteira de vacinação
- [ ] Implementar documentos
- [ ] Implementar mensagens
- [ ] Implementar notificações push
- [ ] Implementar contas a pagar
- [ ] Adicionar testes unitários
- [ ] Implementar upload de foto
- [ ] Adicionar validação de CPF
- [ ] Implementar recuperação de senha

## 👨‍💻 Desenvolvedor

**Cristian da Silva**
- Email: cristian@example.com
- Documentação: `docs/API_PORTAL_PACIENTE.md`

---

*Desenvolvido com Flutter para o Portal do Paciente*