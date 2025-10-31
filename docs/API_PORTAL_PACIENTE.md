# 📱 API do Portal do Paciente - Documentação Completa

## 🎯 Visão Geral

Esta documentação descreve todos os endpoints da API do Portal do Paciente para integração com o app Flutter. A API utiliza autenticação JWT e suporta multitenancy.

### 📋 Informações Gerais
- **Base URL**: `https://seu-dominio.com/api/portal`
- **Autenticação**: JWT Bearer Token
- **Formato**: JSON
- **Encoding**: UTF-8
- **Versionamento**: v1

---

## ⚠️ CONFIGURAÇÃO IMPORTANTE - JWT

### Nova Configuração JWT (2025-01-27)

A API agora utiliza configuração JWT através do arquivo `.env`. **IMPORTANTE**: Copie o arquivo `docs/api/env_example.txt` para `.env` na raiz do projeto.

#### Arquivo .env necessário:
```env
# JWT Configuration
JWT_SECRET=69e2a145eba99afeff3198bd7e004e4710ae8662228d09f8c9fbf8314bbaa0cf
JWT_SECRET_KEY=69e2a145eba99afeff3198bd7e004e4710ae8662228d09f8c9fbf8314bbaa0cf

# Portal Configuration
PORTAL_JWT_EXPIRATION=604800
PORTAL_REFRESH_EXPIRATION=2592000
PORTAL_ISSUER=SoulClinic Portal API
PORTAL_AUDIENCE=SoulClinic Patients
```

#### Estrutura do Token Atualizada:
```json
{
  "paciente_id": 123,
  "cpf": "12345678901",
  "nome": "João Silva",
  "email": "joao@email.com",
  "tenant_id": 1,
  "database_group": "tenant_1",
  "iss": "SoulClinic Portal API",
  "aud": "SoulClinic Patients",
  "iat": 1640908800,
  "exp": 1641513600
}
```

---

## 🔐 Autenticação

### Configuração JWT

A API utiliza JWT (JSON Web Token) para autenticação. A configuração é feita através do arquivo `.env`:

```env
# JWT Configuration
JWT_SECRET=69e2a145eba99afeff3198bd7e004e4710ae8662228d09f8c9fbf8314bbaa0cf
JWT_SECRET_KEY=69e2a145eba99afeff3198bd7e004e4710ae8662228d09f8c9fbf8314bbaa0cf

# Portal Configuration
PORTAL_JWT_EXPIRATION=604800
PORTAL_REFRESH_EXPIRATION=2592000
PORTAL_ISSUER=SoulClinic Portal API
PORTAL_AUDIENCE=SoulClinic Patients
```

### Estrutura do JWT

#### Access Token
```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "paciente_id": 123,
    "cpf": "12345678901",
    "nome": "João Silva",
    "email": "joao@email.com",
    "tenant_id": 1,
    "database_group": "tenant_1",
    "iss": "SoulClinic Portal API",
    "aud": "SoulClinic Patients",
    "iat": 1640908800,
    "exp": 1641513600
  }
}
```

#### Refresh Token
```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "paciente_id": 123,
    "cpf": "12345678901",
    "tenant_id": 1,
    "database_group": "tenant_1",
    "type": "refresh",
    "iss": "SoulClinic Portal API",
    "aud": "SoulClinic Patients",
    "iat": 1640908800,
    "exp": 1641513600
  }
}
```

### Headers Obrigatórios
```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
Accept: application/json
```

### Configuração de Tempo de Expiração
- **Access Token**: 7 dias (604800 segundos)
- **Refresh Token**: 30 dias (2592000 segundos)

---

## 🔢 Tratamento de CPF

### Normalização Automática
A API trata automaticamente CPFs com ou sem máscara:

| Entrada | Processamento | Resultado |
|---------|---------------|-----------|
| `12345678901` | ✅ Aceito diretamente | CPF limpo |
| `123.456.789-01` | ✅ Máscara removida | `12345678901` |
| `123 456 789 01` | ✅ Espaços removidos | `12345678901` |
| `123-456-789-01` | ✅ Hífens removidos | `12345678901` |

### Validação
- **Formato**: Deve ter exatamente 11 dígitos
- **Algoritmo**: Validação completa do CPF (dígitos verificadores)
- **Rejeição**: CPFs inválidos (ex: `11111111111`) são rejeitados

### Busca no Banco
1. **Primeira tentativa**: Busca com CPF original
2. **Segunda tentativa**: Busca com CPF normalizado (sem máscara)
3. **Resultado**: Retorna dados se encontrar em qualquer formato

---

## 📊 Status dos Endpoints

### ✅ Endpoints Funcionando (100%)
- **Autenticação**: Login, Refresh, Logout, Verificar CPF, Reset Senha, Alterar Senha
- **Dashboard**: Dados reais com estatísticas, agendamentos e notificações
- **Perfil**: Buscar e atualizar dados do paciente

### 🔧 Endpoints Implementados (Precisa Teste)
- **Agendamentos**: Listar, Detalhes, Cancelar, Solicitar, Horários Disponíveis
- **Carteira de Vacinação**: Listar, Detalhes, Gerar PDF
- **Documentos**: Listar, Download
- **Mensagens**: Listar, Detalhes, Marcar Lida, Enviar
- **Notificações**: Listar, Marcar Lida, Configurações
- **Configurações**: Buscar, Alterar Senha, Notificações

### 📋 Resumo de Implementação
- **Total de Endpoints**: 25+
- **Funcionando**: 8 endpoints principais
- **Implementados**: 17+ endpoints adicionais
- **Dados Reais**: ✅ Dashboard e Perfil retornam dados reais do paciente
- **Autenticação JWT**: ✅ Sistema completo implementado

---

## 🚀 Endpoints da API

### 1. 🔑 Autenticação

#### 1.1 Login
```http
POST /api/portal/auth/login
```

**Request Body:**
```json
{
  "cpf": "12345678901",
  "senha": "senha123",
  "db_group": "tenant_1"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Login realizado com sucesso",
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "refresh_token": "refresh_token_here",
    "user": {
      "id": 123,
      "nome": "João Silva",
      "email": "joao@email.com",
      "cpf": "12345678901",
      "telefone": "(11) 99999-9999",
      "data_nascimento": "1990-01-01",
      "sexo": "M",
      "db_group": "tenant_1"
    }
  }
}
```

**Response (401):**
```json
{
  "success": false,
  "message": "Credenciais inválidas"
}
```

**Response (400):**
```json
{
  "success": false,
  "message": "Dados inválidos",
  "errors": {
    "cpf": ["CPF é obrigatório"],
    "senha": ["Senha é obrigatória"]
  }
}
```

**Response (422):**
```json
{
  "success": false,
  "message": "CPF inválido"
}
```

**Response (500):**
```json
{
  "success": false,
  "message": "Erro interno do servidor"
}
```

#### 1.2 Refresh Token
```http
POST /api/portal/auth/refresh
```

**Request Body:**
```json
{
  "refresh_token": "refresh_token_here"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Token renovado com sucesso",
  "data": {
    "token": "new_jwt_token_here",
    "refresh_token": "new_refresh_token_here"
  }
}
```

**Response (401):**
```json
{
  "success": false,
  "message": "Refresh token inválido ou expirado"
}
```

**Response (400):**
```json
{
  "success": false,
  "message": "Refresh token é obrigatório"
}
```

**Response (500):**
```json
{
  "success": false,
  "message": "Erro interno do servidor"
}
```

#### 1.3 Logout
```http
POST /api/portal/auth/logout
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Response (200):**
```json
{
  "success": true,
  "message": "Logout realizado com sucesso"
}
```

**Response (401):**
```json
{
  "success": false,
  "message": "Token inválido ou expirado"
}
```

**Response (500):**
```json
{
  "success": false,
  "message": "Erro interno do servidor"
}
```

#### 1.4 Verificar CPF
```http
POST /api/portal/auth/verificar-cpf
```

**Request Body:**
```json
{
  "cpf": "12345678901",
  "db_group": "tenant_1"
}
```

**Response (200):**
```json
{
  "success": true,
  "existe": true,
  "cpf": "12345678901",
  "cpf_normalizado": "12345678901",
  "data": {
    "paciente": {
      "id": 123,
      "nome": "João Silva",
      "email": "joao@email.com",
      "cpf": "12345678901",
      "tenant_nome": "Clínica",
      "database_group": "group_clinica_dutra_65"
    }
  }
}
```

**Response (200) - CPF não encontrado:**
```json
{
  "success": true,
  "existe": false,
  "cpf": "12345678901",
  "cpf_normalizado": "12345678901",
  "data": {
    "paciente": null
  }
}
```

**Response (400):**
```json
{
  "success": false,
  "message": "CPF é obrigatório"
}
```

**Response (422):**
```json
{
  "success": false,
  "message": "CPF inválido"
}
```

**Response (500):**
```json
{
  "success": false,
  "message": "Erro interno do servidor"
}
```

#### 1.5 Reset de Senha (Esqueci minha senha)
```http
POST /api/portal/auth/forgot-password
```

**Request Body:**
```json
{
  "cpf": "12345678901",
  "db_group": "tenant_1"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Nova senha gerada e enviada por email",
  "data": {
    "email_enviado": true,
    "email_erro": null,
    "paciente_email": "joao@email.com",
    "paciente_nome": "João Silva",
    "nova_senha": "9yM@rHAdi3l1"
  }
}
```

**Response (200) - Erro no envio do email:**
```json
{
  "success": true,
  "message": "Nova senha gerada, mas houve erro ao enviar por email",
  "data": {
    "email_enviado": false,
    "email_erro": "Erro de conexão SMTP",
    "paciente_email": "joao@email.com",
    "paciente_nome": "João Silva",
    "nova_senha": "9yM@rHAdi3l1"
  }
}
```

**Response (404):**
```json
{
  "success": false,
  "message": "CPF não encontrado na base de dados"
}
```

**Response (400):**
```json
{
  "success": false,
  "message": "CPF é obrigatório"
}
```

**Response (422):**
```json
{
  "success": false,
  "message": "CPF inválido"
}
```

**Response (500):**
```json
{
  "success": false,
  "message": "Erro interno do servidor"
}
```

**Fluxo Simplificado:**
1. Paciente informa apenas o CPF
2. Sistema verifica se CPF existe no CRM
3. Gera nova senha segura automaticamente
4. Atualiza senha no banco de dados
5. Envia nova senha por email
6. **Não requer verificação de senha atual**

#### 1.6 Alterar Senha (Com senha atual)
```http
POST /api/portal/auth/change-password
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Request Body:**
```json
{
  "paciente_id": 123,
  "senha_atual": "senhaAtual123",
  "nova_senha": "NovaSenha123!@#",
  "db_group": "tenant_1"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Senha alterada com sucesso"
}
```

**Response (401):**
```json
{
  "success": false,
  "message": "Token inválido ou expirado"
}
```

**Response (400):**
```json
{
  "success": false,
  "message": "Dados inválidos",
  "errors": {
    "senha_atual": ["Senha atual é obrigatória"],
    "nova_senha": ["Nova senha é obrigatória"]
  }
}
```

**Response (422):**
```json
{
  "success": false,
  "message": "Senha atual incorreta"
}
```

**Response (422) - Validação de senha:**
```json
{
  "success": false,
  "message": "Nova senha não atende aos critérios de segurança",
  "errors": {
    "nova_senha": ["A senha deve ter pelo menos 8 caracteres, 1 maiúscula, 1 minúscula, 1 número e 1 caractere especial"]
  }
}
```

**Response (500):**
```json
{
  "success": false,
  "message": "Erro interno do servidor"
}
```

**Critérios de Validação da Senha:**
- Mínimo 8 caracteres
- Máximo 50 caracteres
- Pelo menos 1 letra maiúscula
- Pelo menos 1 letra minúscula
- Pelo menos 1 número
- Pelo menos 1 caractere especial
- Não pode conter espaços

---

### 2. 📊 Dashboard

#### 2.1 Dashboard Principal
```http
GET /api/portal/dashboard
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Query Parameters:**
- `unidade_id` (opcional): ID da unidade de atendimento

**Response (200):**
```json
{
  "success": true,
  "message": "Dados do dashboard carregados com sucesso",
  "data": {
    "estatisticas": {
      "total_agendamentos": 15,
      "agendamentos_hoje": 3,
      "agendamentos_pendentes": 8,
      "agendamentos_cancelados": 2,
      "total_consultas": 45,
      "consultas_mes": 12,
      "total_vacinas": 23,
      "vacinas_pendentes": 5
    },
    "proximos_agendamentos": [
      {
        "id": 123,
        "data": "2025-08-26",
        "hora": "14:30",
        "tipo": "Consulta Médica",
        "profissional": "Dr. Maria Santos",
        "unidade": "Clínica Central",
        "sala": "Sala 3",
        "status": "confirmado",
        "observacoes": "Trazer exames recentes",
        "created_at": "2025-08-20T10:30:00Z"
      }
    ],
    "notificacoes_recentes": [
      {
        "id": 456,
        "titulo": "Agendamento Confirmado",
        "mensagem": "Sua consulta foi confirmada para amanhã",
        "data": "2025-08-25T10:30:00Z",
        "lida": false,
        "tipo": "sistema"
      }
    ],
    "paciente_id": 1,
    "database_group": "group_clinica_dutra_65"
  }
}
```

**Response (401):**
```json
{
  "success": false,
  "message": "Token inválido ou expirado"
}
```

**Response (500):**
```json
{
  "success": false,
  "message": "Erro ao carregar dados do dashboard"
}
```

---

### 3. 👤 Perfil do Paciente

#### 3.1 Buscar Perfil
```http
GET /api/portal/perfil
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "1",
    "convenio_id": null,
    "email": "luanadutradc@gmail.com",
    "cpf": "065.971.289-07",
    "nome": "Paciente teste",
    "nome_social": null,
    "profissao": null,
    "data_nascimento": null,
    "genero": "M",
    "celular": "(49) 99112-5528",
    "telefone": "(49) 99112-5528",
    "telefone_servico": null,
    "telefone_responsavel": null,
    "preferencia_contato": null,
    "foto": null,
    "cep": null,
    "logradouro": null,
    "numero": null,
    "bairro": null,
    "cidade": null,
    "uf": null,
    "complemento": null,
    "ativo": "t",
    "altura": null,
    "obs": null,
    "obs_medicas": null,
    "obs_enfermagem": null,
    "tipo_sanguineo": "AB+",
    "numero_carteira_convenio": null,
    "validade_carteiro_convenio": null,
    "data_expedicao_carteiro_convenio": null,
    "acomodacao_convenio": null,
    "abrangencia": null,
    "alergias": null,
    "created_at": null,
    "updated_at": "2025-10-28 14:36:12",
    "deleted_at": null
  }
}
```

**Response (401):**
```json
{
  "success": false,
  "message": "Token inválido ou expirado"
}
```

**Response (404):**
```json
{
  "success": false,
  "message": "Paciente não encontrado"
}
```

**Response (500):**
```json
{
  "success": false,
  "message": "Erro interno do servidor"
}
```

#### 3.2 Atualizar Perfil
```http
PUT /api/portal/perfil
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Request Body:**
```json
{
  "nome": "João Silva Santos",
  "telefone": "(11) 99999-9999",
  "celular": "(11) 88888-8888",
  "endereco": {
    "cep": "01234-567",
    "logradouro": "Rua das Flores",
    "numero": "123",
    "complemento": "Apto 45",
    "bairro": "Centro",
    "cidade": "São Paulo",
    "estado": "SP"
  },
  "preferencias": {
    "notificacoes_email": true,
    "notificacoes_sms": false,
    "notificacoes_push": true
  }
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Dados atualizados com sucesso!",
  "data": {
    "id": "1",
    "nome": "João Silva Santos",
    "email": "joao@email.com",
    "telefone": "(11) 99999-9999"
  }
}
```

**Response (401):**
```json
{
  "success": false,
  "message": "Token inválido ou expirado"
}
```

**Response (400):**
```json
{
  "success": false,
  "message": "Dados inválidos",
  "errors": {
    "nome": ["Nome é obrigatório"],
    "email": ["Email é obrigatório"]
  }
}
```

**Response (422):**
```json
{
  "success": false,
  "message": "Email já está em uso por outro paciente"
}
```

**Response (500):**
```json
{
  "success": false,
  "message": "Erro interno do servidor"
}
```

#### 3.3 Upload de Foto
```http
POST /api/portal/perfil/foto
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
Content-Type: multipart/form-data
```

**Request Body:**
```form-data
foto: [arquivo de imagem]
```

**Response (200):**
```json
{
  "success": true,
  "message": "Foto atualizada com sucesso",
  "data": {
    "foto_url": "https://seu-dominio.com/uploads/fotos/paciente_123.jpg"
  }
}
```

---

### 4. 📅 Agendamentos

#### 4.1 Listar Agendamentos
```http
GET /api/portal/agendamentos
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Query Parameters:**
- `status` (opcional): `todos`, `confirmados`, `pendentes`, `cancelados`
- `data_inicio` (opcional): `2025-08-01`
- `data_fim` (opcional): `2025-08-31`
- `tipo` (opcional): `consulta`, `vacina`, `exame`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "agendamentos": [
      {
        "id": 123,
        "data": "2025-08-26",
        "hora": "14:30",
        "tipo": "Consulta",
        "profissional": "Dr. Maria Santos",
        "unidade": "Clínica Central",
        "sala": "Sala 3",
        "status": "confirmado",
        "observacoes": "Trazer exames recentes",
        "created_at": "2025-08-20T10:30:00Z"
      }
    ],
    "paginacao": {
      "total": 15,
      "pagina_atual": 1,
      "por_pagina": 10,
      "total_paginas": 2
    }
  }
}
```

#### 4.2 Detalhes do Agendamento
```http
GET /api/portal/agendamentos/{id}
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 123,
    "data": "2025-08-26",
    "hora": "14:30",
    "tipo": "Consulta",
    "profissional": {
      "id": 456,
      "nome": "Dr. Maria Santos",
      "especialidade": "Clínico Geral",
      "crm": "12345-SP"
    },
    "unidade": {
      "id": 789,
      "nome": "Clínica Central",
      "endereco": "Rua das Flores, 123",
      "telefone": "(11) 3333-3333"
    },
    "sala": "Sala 3",
    "status": "confirmado",
    "observacoes": "Trazer exames recentes",
    "protocolo": "AGD-2025-00123",
    "created_at": "2025-08-20T10:30:00Z",
    "updated_at": "2025-08-25T15:45:00Z"
  }
}
```

#### 4.3 Cancelar Agendamento
```http
POST /api/portal/agendamentos/{id}/cancelar
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Request Body:**
```json
{
  "motivo": "Imprevisto pessoal"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Agendamento cancelado com sucesso"
}
```

#### 4.4 Solicitar Agendamento
```http
POST /api/portal/agendamentos/solicitar
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Request Body:**
```json
{
  "tipo": "consulta",
  "especialidade_id": 1,
  "profissional_id": 456,
  "unidade_id": 789,
  "data_preferencia": "2025-09-01",
  "hora_preferencia": "14:00",
  "observacoes": "Primeira consulta"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Solicitação de agendamento enviada com sucesso",
  "data": {
    "protocolo": "SOL-2025-00123"
  }
}
```

---

### 5. 💉 Carteira de Vacinação

#### 5.1 Buscar Carteira
```http
GET /api/portal/carteira-vacinacao
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "paciente": {
      "id": 123,
      "nome": "João Silva",
      "data_nascimento": "1990-01-01"
    },
    "vacinas": [
      {
        "id": 456,
        "nome": "COVID-19",
        "dose": "1ª Dose",
        "data_aplicacao": "2025-01-15",
        "data_proxima_dose": "2025-02-15",
        "status": "aplicada",
        "lote": "LOTE123",
        "aplicador": "Dr. Maria Santos",
        "unidade": "Clínica Central",
        "observacoes": "Sem reações adversas"
      }
    ],
    "estatisticas": {
      "total_vacinas": 23,
      "vacinas_pendentes": 5,
      "vacinas_atrasadas": 2
    }
  }
}
```

#### 5.2 Detalhes da Vacina
```http
GET /api/portal/carteira-vacinacao/detalhes/{id}
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 456,
    "nome": "COVID-19",
    "dose": "1ª Dose",
    "data_aplicacao": "2025-01-15",
    "data_proxima_dose": "2025-02-15",
    "status": "aplicada",
    "lote": "LOTE123",
    "aplicador": "Dr. Maria Santos",
    "unidade": "Clínica Central",
    "observacoes": "Sem reações adversas",
    "reacoes_adversas": [],
    "documentos": [
      {
        "id": 789,
        "nome": "Comprovante de Vacinação",
        "url": "https://seu-dominio.com/documentos/vacina_456.pdf"
      }
    ]
  }
}
```

#### 5.3 Gerar PDF da Carteira
```http
GET /api/portal/carteira-vacinacao/pdf
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "pdf_url": "https://seu-dominio.com/documentos/carteira_vacina_123.pdf",
    "expira_em": "2025-08-26T10:30:00Z"
  }
}
```

---

### 6. 📄 Documentos

#### 6.1 Listar Documentos
```http
GET /api/portal/documentos
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Query Parameters:**
- `tipo` (opcional): `exame`, `receita`, `atestado`, `relatorio`
- `data_inicio` (opcional): `2025-08-01`
- `data_fim` (opcional): `2025-08-31`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "documentos": [
      {
        "id": 123,
        "nome": "Exame de Sangue",
        "tipo": "exame",
        "data": "2025-08-20",
        "profissional": "Dr. Maria Santos",
        "tamanho": "2.5 MB",
        "status": "disponivel"
      }
    ],
    "paginacao": {
      "total": 25,
      "pagina_atual": 1,
      "por_pagina": 10,
      "total_paginas": 3
    }
  }
}
```

#### 6.2 Download de Documento
```http
GET /api/portal/documentos/{id}/download
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "download_url": "https://seu-dominio.com/documentos/exame_123.pdf",
    "expira_em": "2025-08-26T10:30:00Z",
    "nome_arquivo": "exame_sangue_20250820.pdf"
  }
}
```

---

### 7. 💬 Mensagens

#### 7.1 Listar Mensagens
```http
GET /api/portal/mensagens
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Query Parameters:**
- `status` (opcional): `todas`, `lidas`, `nao_lidas`
- `tipo` (opcional): `sistema`, `profissional`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "mensagens": [
      {
        "id": 123,
        "titulo": "Agendamento Confirmado",
        "mensagem": "Sua consulta foi confirmada para amanhã às 14:30",
        "tipo": "sistema",
        "data": "2025-08-25T10:30:00Z",
        "lida": false,
        "prioridade": "normal"
      }
    ],
    "paginacao": {
      "total": 45,
      "pagina_atual": 1,
      "por_pagina": 10,
      "total_paginas": 5
    }
  }
}
```

#### 7.2 Detalhes da Mensagem
```http
GET /api/portal/mensagens/{id}
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 123,
    "titulo": "Agendamento Confirmado",
    "mensagem": "Sua consulta foi confirmada para amanhã às 14:30",
    "tipo": "sistema",
    "data": "2025-08-25T10:30:00Z",
    "lida": false,
    "prioridade": "normal",
    "remetente": {
      "id": 456,
      "nome": "Sistema",
      "tipo": "sistema"
    },
    "anexos": []
  }
}
```

#### 7.3 Marcar como Lida
```http
PUT /api/portal/mensagens/{id}/ler
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Response (200):**
```json
{
  "success": true,
  "message": "Mensagem marcada como lida"
}
```

#### 7.4 Enviar Mensagem
```http
POST /api/portal/mensagens
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Request Body:**
```json
{
  "destinatario_id": 456,
  "assunto": "Dúvida sobre medicamento",
  "mensagem": "Gostaria de esclarecer sobre a dosagem do medicamento",
  "prioridade": "normal"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Mensagem enviada com sucesso",
  "data": {
    "id": 789
  }
}
```

---

### 8. 🔔 Notificações

#### 8.1 Listar Notificações
```http
GET /api/portal/notificacoes
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Query Parameters:**
- `status` (opcional): `todas`, `lidas`, `nao_lidas`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "notificacoes": [
      {
        "id": 123,
        "titulo": "Lembrete de Consulta",
        "mensagem": "Sua consulta é amanhã às 14:30",
        "tipo": "lembrete",
        "data": "2025-08-25T10:30:00Z",
        "lida": false,
        "acao": {
          "tipo": "agendamento",
          "id": 456
        }
      }
    ],
    "paginacao": {
      "total": 12,
      "pagina_atual": 1,
      "por_pagina": 10,
      "total_paginas": 2
    }
  }
}
```

#### 8.2 Marcar como Lida
```http
PUT /api/portal/notificacoes/{id}/ler
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Response (200):**
```json
{
  "success": true,
  "message": "Notificação marcada como lida"
}
```

#### 8.3 Configurações de Notificação
```http
PUT /api/portal/notificacoes/configuracoes
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Request Body:**
```json
{
  "email": true,
  "sms": false,
  "push": true,
  "lembretes_agendamento": true,
  "lembretes_vacina": true,
  "novidades": false
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Configurações atualizadas com sucesso"
}
```

---

### 9. 💰 Contas a Pagar

#### 9.1 Listar Contas
```http
GET /api/portal/contas-pagar
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Query Parameters:**
- `status` (opcional): `todas`, `pendentes`, `pagas`, `vencidas`
- `data_inicio` (opcional): `2025-08-01`
- `data_fim` (opcional): `2025-08-31`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "contas": [
      {
        "id": 123,
        "descricao": "Consulta Dr. Maria Santos",
        "valor": 150.00,
        "data_vencimento": "2025-08-30",
        "data_pagamento": null,
        "status": "pendente",
        "forma_pagamento": "boleto",
        "protocolo": "FAT-2025-00123"
      }
    ],
    "estatisticas": {
      "total_pendente": 450.00,
      "total_pago": 1200.00,
      "total_vencido": 150.00
    }
  }
}
```

#### 9.2 Detalhes da Conta
```http
GET /api/portal/contas-pagar/{id}
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 123,
    "descricao": "Consulta Dr. Maria Santos",
    "valor": 150.00,
    "data_vencimento": "2025-08-30",
    "data_pagamento": null,
    "status": "pendente",
    "forma_pagamento": "boleto",
    "protocolo": "FAT-2025-00123",
    "agendamento": {
      "id": 456,
      "data": "2025-08-25",
      "hora": "14:30",
      "profissional": "Dr. Maria Santos"
    },
    "pagamento": {
      "boleto": {
        "linha_digitavel": "12345.67890 12345.678901 12345.678901 1 12345678901234",
        "codigo_barras": "12345678901234567890123456789012345678901234",
        "pdf_url": "https://seu-dominio.com/boletos/boleto_123.pdf"
      },
      "pix": {
        "qr_code": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",
        "qr_code_text": "00020126580014br.gov.bcb.pix0136...",
        "expira_em": "2025-08-26T10:30:00Z"
      }
    }
  }
}
```

#### 9.3 Gerar Cobrança
```http
POST /api/portal/contas-pagar/{id}/gerar-cobranca
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Request Body:**
```json
{
  "forma_pagamento": "boleto",
  "data_vencimento": "2025-08-30"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Cobrança gerada com sucesso",
  "data": {
    "boleto": {
      "linha_digitavel": "12345.67890 12345.678901 12345.678901 1 12345678901234",
      "codigo_barras": "12345678901234567890123456789012345678901234",
      "pdf_url": "https://seu-dominio.com/boletos/boleto_123.pdf"
    },
    "pix": {
      "qr_code": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",
      "qr_code_text": "00020126580014br.gov.bcb.pix0136...",
      "expira_em": "2025-08-26T10:30:00Z"
    }
  }
}
```

---

### 10. ⚙️ Configurações

#### 10.1 Buscar Configurações
```http
GET /api/portal/configuracoes
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "notificacoes": {
      "email": true,
      "sms": false,
      "push": true,
      "lembretes_agendamento": true,
      "lembretes_vacina": true,
      "novidades": false
    },
    "privacidade": {
      "compartilhar_dados": false,
      "receber_marketing": false
    },
    "seguranca": {
      "autenticacao_2fatores": false,
      "ultimo_login": "2025-08-25T10:30:00Z"
    }
  }
}
```

#### 10.2 Alterar Senha
```http
PUT /api/portal/configuracoes/senha
```

**Headers:**
```http
Authorization: Bearer <jwt_token>
```

**Request Body:**
```json
{
  "senha_atual": "senha123",
  "nova_senha": "novaSenha456",
  "confirmar_senha": "novaSenha456"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Senha alterada com sucesso"
}
```

---

## 🚨 Códigos de Erro

### Erros HTTP Comuns

| Código | Descrição | Exemplo |
|--------|-----------|---------|
| 400 | Bad Request | Dados inválidos |
| 401 | Unauthorized | Token inválido ou expirado |
| 403 | Forbidden | Sem permissão |
| 404 | Not Found | Recurso não encontrado |
| 422 | Unprocessable Entity | Validação falhou |
| 500 | Internal Server Error | Erro interno do servidor |

### Estrutura de Erro
```json
{
  "success": false,
  "message": "Descrição do erro",
  "errors": {
    "campo": ["Mensagem de erro específica"]
  }
}
```

---

## 🔧 Testes da API

### 1. Configurar Ambiente
1. Importe a coleção: `docs/api/SoulClinic_Portal_API.postman_collection.json`
2. Importe o ambiente: `docs/api/SoulClinic_Portal_API.postman_environment.json`
3. Configure o arquivo `.env` na raiz do projeto

### 2. Fluxo de Teste
1. **Verificar CPF**: `POST /api/portal/auth/verificar-cpf`
2. **Login**: `POST /api/portal/auth/login` (obtém o token)
3. **Atualizar Paciente**: `PUT /api/portal/perfil`

### 3. Headers Necessários
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
Accept: application/json
```

### 4. Exemplo de Teste Manual
1. **URL**: `PUT http://localhost:8080/api/portal/perfil`
2. **Headers**:
   ```
   Authorization: Bearer SEU_TOKEN_AQUI
   Content-Type: application/json
   ```
3. **Body**:
   ```json
   {
     "nome": "Teste Atualização",
     "email": "teste@email.com",
     "telefone": "(11) 99999-9999"
   }
   ```

### 5. Teste de Conectividade
```bash
curl -X GET https://seu-dominio.com/api/portal/health
```

### 6. Teste de Autenticação
```bash
curl -X POST https://seu-dominio.com/api/portal/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "cpf": "12345678901",
    "senha": "senha123",
    "db_group": "tenant_1"
  }'
```

### 7. Teste de Endpoint Protegido
```bash
curl -X GET https://seu-dominio.com/api/portal/dashboard \
  -H "Authorization: Bearer SEU_JWT_TOKEN"
```

---

## 📱 Implementação no Flutter

### 1. Configuração Base

```dart
class ApiService {
  static const String baseUrl = 'https://seu-dominio.com/api/portal';
  static const String tokenKey = 'jwt_token';
  
  static Future<Map<String, String>> getHeaders() async {
    final token = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString(tokenKey));
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
```

### 2. Autenticação

```dart
class AuthService {
  static Future<Map<String, dynamic>> login({
    required String cpf,
    required String senha,
    required String dbGroup,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/auth/login'),
      headers: await ApiService.getHeaders(),
      body: jsonEncode({
        'cpf': cpf,
        'senha': senha,
        'db_group': dbGroup,
      }),
    );
    
    return jsonDecode(response.body);
  }
}
```

### 3. Dashboard

```dart
class DashboardService {
  static Future<Map<String, dynamic>> getDashboard() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/dashboard'),
      headers: await ApiService.getHeaders(),
    );
    
    return jsonDecode(response.body);
  }
}
```

### 4. Agendamentos

```dart
class AgendamentosService {
  static Future<Map<String, dynamic>> getAgendamentos({
    String? status,
    String? dataInicio,
    String? dataFim,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (dataInicio != null) queryParams['data_inicio'] = dataInicio;
    if (dataFim != null) queryParams['data_fim'] = dataFim;
    
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/agendamentos')
          .replace(queryParameters: queryParams),
      headers: await ApiService.getHeaders(),
    );
    
    return jsonDecode(response.body);
  }
}
```

### 5. Atualização de Perfil (CORRIGIDO)

```dart
Future<bool> atualizarPaciente(Map<String, dynamic> data) async {
  try {
    // 1. Obter token
    final token = await getStoredToken();
    if (token == null) {
      print('❌ Token não encontrado');
      return false;
    }

    // 2. Fazer requisição com header Authorization
    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/perfil'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // ← CORRIGIDO
      },
      body: jsonEncode(data),
    );

    // 3. Verificar resposta
    if (response.statusCode == 200) {
      print('✅ Paciente atualizado com sucesso');
      return true;
    } else if (response.statusCode == 401) {
      print('❌ Token inválido ou expirado');
      // Fazer login novamente
      return false;
    } else {
      print('❌ Erro: ${response.statusCode} - ${response.body}');
      return false;
    }
  } catch (e) {
    print('❌ Erro na requisição: $e');
    return false;
  }
}
```

---

## 📋 Campos Permitidos para Atualização

Apenas estes campos podem ser atualizados:

```json
{
  "nome": "string",
  "email": "string", 
  "telefone": "string",
  "celular": "string",
  "genero": "M|F|O",
  "profissao": "string",
  "tipo_sanguineo": "O+|O-|A+|A-|B+|B-|AB+|AB-",
  "data_nascimento": "YYYY-MM-DD",
  "cpf": "12345678901"
}
```

## ✅ Validações Implementadas

- **CPF**: Validação de formato e verificação de duplicidade
- **Email**: Validação de formato e verificação de duplicidade  
- **Nome**: Mínimo 3 caracteres
- **Data de Nascimento**: Formato YYYY-MM-DD

## 📞 Suporte

Para dúvidas sobre a API:

- **Desenvolvedor**: Cristian da Silva
- **Email**: cristian@example.com
- **Documentação**: Este arquivo
- **Base URL**: `https://seu-dominio.com/api/portal`

---

## 📋 Resumo Completo de Endpoints

### 🔑 Autenticação (6 endpoints)
| Método | Endpoint | Status | Descrição |
|--------|----------|--------|-----------|
| POST | `/auth/login` | ✅ | Login com CPF e senha |
| POST | `/auth/refresh` | ✅ | Renovar token de acesso |
| POST | `/auth/logout` | ✅ | Logout do usuário |
| POST | `/auth/verificar-cpf` | ✅ | Verificar se CPF existe |
| POST | `/auth/forgot-password` | ✅ | Reset de senha por CPF |
| POST | `/auth/change-password` | ✅ | Alterar senha com senha atual |

### 📊 Dashboard (1 endpoint)
| Método | Endpoint | Status | Descrição |
|--------|----------|--------|-----------|
| GET | `/dashboard` | ✅ | Dados do dashboard principal |

### 👤 Perfil (3 endpoints)
| Método | Endpoint | Status | Descrição |
|--------|----------|--------|-----------|
| GET | `/perfil` | ✅ | Buscar dados do perfil |
| PUT | `/perfil` | ✅ | Atualizar dados do perfil |
| POST | `/perfil/foto` | 🔧 | Upload de foto |

### 📅 Agendamentos (5 endpoints)
| Método | Endpoint | Status | Descrição |
|--------|----------|--------|-----------|
| GET | `/agendamentos` | 🔧 | Listar agendamentos |
| GET | `/agendamentos/{id}` | 🔧 | Detalhes do agendamento |
| POST | `/agendamentos/{id}/cancelar` | 🔧 | Cancelar agendamento |
| POST | `/agendamentos/solicitar` | 🔧 | Solicitar agendamento |
| GET | `/agendamentos/horarios-disponiveis` | 🔧 | Horários disponíveis |

### 💉 Carteira de Vacinação (3 endpoints)
| Método | Endpoint | Status | Descrição |
|--------|----------|--------|-----------|
| GET | `/carteira-vacinacao` | 🔧 | Listar carteira |
| GET | `/carteira-vacinacao/detalhes/{id}` | 🔧 | Detalhes da vacina |
| GET | `/carteira-vacinacao/pdf` | 🔧 | Gerar PDF da carteira |

### 📄 Documentos (2 endpoints)
| Método | Endpoint | Status | Descrição |
|--------|----------|--------|-----------|
| GET | `/documentos` | 🔧 | Listar documentos |
| GET | `/documentos/{id}/download` | 🔧 | Download de documento |

### 💬 Mensagens (4 endpoints)
| Método | Endpoint | Status | Descrição |
|--------|----------|--------|-----------|
| GET | `/mensagens` | 🔧 | Listar mensagens |
| GET | `/mensagens/{id}` | 🔧 | Detalhes da mensagem |
| PUT | `/mensagens/{id}/marcar-lida` | 🔧 | Marcar como lida |
| POST | `/mensagens/enviar` | 🔧 | Enviar mensagem |

### 🔔 Notificações (3 endpoints)
| Método | Endpoint | Status | Descrição |
|--------|----------|--------|-----------|
| GET | `/notificacoes` | 🔧 | Listar notificações |
| PUT | `/notificacoes/{id}/marcar-lida` | 🔧 | Marcar como lida |
| PUT | `/notificacoes/configuracoes` | 🔧 | Configurações de notificação |

### ⚙️ Configurações (3 endpoints)
| Método | Endpoint | Status | Descrição |
|--------|----------|--------|-----------|
| GET | `/configuracoes` | 🔧 | Buscar configurações |
| PUT | `/configuracoes/senha` | 🔧 | Alterar senha |
| PUT | `/configuracoes/notificacoes` | 🔧 | Configurações de notificação |

### 📊 Estatísticas
- **Total de Endpoints**: 30
- **Funcionando (✅)**: 10 endpoints
- **Implementados (🔧)**: 20 endpoints
- **Cobertura**: 100% dos módulos principais

## 📝 Histórico de Versões

- **v1.2** (28/01/2025): Documentação completa atualizada
  - Adicionado status detalhado de todos os endpoints
  - Retornos de sucesso e erro para cada endpoint
  - Resumo completo de implementação
  - Dados reais nos exemplos de resposta

- **v1.1** (27/01/2025): Documentação unificada
  - Configuração JWT via arquivo `.env`
  - Login por CPF (não email)
  - Correção de problemas de autenticação
  - Exemplos de código Flutter atualizados
  - Coleção Postman completa

- **v1.0** (25/08/2025): Documentação inicial
  - Endpoints de autenticação
  - Dashboard e perfil
  - Agendamentos e carteira de vacinação
  - Documentos e mensagens
  - Notificações e configurações
  - Contas a pagar

---

*Esta documentação deve ser atualizada conforme a API evolui.*
