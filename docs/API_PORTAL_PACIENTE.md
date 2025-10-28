# 📱 API do Portal do Paciente - Documentação para App Flutter

## 🎯 Visão Geral

Esta documentação descreve todos os endpoints da API do Portal do Paciente para integração com o app Flutter. A API utiliza autenticação JWT e suporta multitenancy.

### 📋 Informações Gerais
- **Base URL**: `https://seu-dominio.com/api/portal`
- **Autenticação**: JWT Bearer Token
- **Formato**: JSON
- **Encoding**: UTF-8
- **Versionamento**: v1

---

## 🔐 Autenticação

### Estrutura do JWT
```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "user_id": 123,
    "email": "paciente@email.com",
    "db_group": "soulclinic",
    "exp": 1640995200,
    "iat": 1640908800
  }
}
```

### Headers Obrigatórios
```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
Accept: application/json
```

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
  "email": "paciente@email.com",
  "senha": "senha123",
  "db_group": "soulclinic"
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
      "email": "paciente@email.com",
      "cpf": "123.456.789-00",
      "telefone": "(11) 99999-9999",
      "data_nascimento": "1990-01-01",
      "sexo": "M",
      "db_group": "soulclinic"
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

#### 1.4 Verificar CPF
```http
POST /api/portal/auth/verificar-cpf
```

**Request Body:**
```json
{
  "cpf": "123.456.789-00",
  "db_group": "soulclinic"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "CPF encontrado",
  "data": {
    "existe": true,
    "paciente": {
      "id": 123,
      "nome": "João Silva",
      "email": "paciente@email.com"
    }
  }
}
```

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
        "tipo": "Consulta",
        "profissional": "Dr. Maria Santos",
        "unidade": "Clínica Central",
        "status": "confirmado"
      }
    ],
    "notificacoes_recentes": [
      {
        "id": 456,
        "titulo": "Agendamento Confirmado",
        "mensagem": "Sua consulta foi confirmada para amanhã",
        "data": "2025-08-25T10:30:00Z",
        "lida": false
      }
    ]
  }
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
    "id": 123,
    "nome": "João Silva",
    "email": "paciente@email.com",
    "cpf": "123.456.789-00",
    "telefone": "(11) 99999-9999",
    "celular": "(11) 88888-8888",
    "data_nascimento": "1990-01-01",
    "sexo": "M",
    "endereco": {
      "cep": "01234-567",
      "logradouro": "Rua das Flores",
      "numero": "123",
      "complemento": "Apto 45",
      "bairro": "Centro",
      "cidade": "São Paulo",
      "estado": "SP"
    },
    "foto_url": "https://seu-dominio.com/uploads/fotos/paciente_123.jpg",
    "preferencias": {
      "notificacoes_email": true,
      "notificacoes_sms": true,
      "notificacoes_push": true
    }
  }
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
  "message": "Perfil atualizado com sucesso"
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
    required String email,
    required String senha,
    required String dbGroup,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/auth/login'),
      headers: await ApiService.getHeaders(),
      body: jsonEncode({
        'email': email,
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

---

## 🔧 Testes da API

### 1. Teste de Conectividade
```bash
curl -X GET https://seu-dominio.com/api/portal/health
```

### 2. Teste de Autenticação
```bash
curl -X POST https://seu-dominio.com/api/portal/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teste@email.com",
    "senha": "senha123",
    "db_group": "soulclinic"
  }'
```

### 3. Teste de Endpoint Protegido
```bash
curl -X GET https://seu-dominio.com/api/portal/dashboard \
  -H "Authorization: Bearer SEU_JWT_TOKEN"
```

---

## 📞 Suporte

Para dúvidas sobre a API:

- **Desenvolvedor**: Cristian da Silva
- **Email**: cristian@example.com
- **Documentação**: Este arquivo
- **Base URL**: `https://seu-dominio.com/api/portal`

---

## 📝 Histórico de Versões

- **v1.0** (25/08/2025): Documentação inicial
  - Endpoints de autenticação
  - Dashboard e perfil
  - Agendamentos e carteira de vacinação
  - Documentos e mensagens
  - Notificações e configurações
  - Contas a pagar

---

*Esta documentação deve ser atualizada conforme a API evolui.*
