# Checklist de Testes - Portal do Paciente

## 🔴 Testes Críticos (Obrigatórios antes de publicar)

### 1. Autenticação e Segurança
- [ ] **Login com CPF e senha**
  - [X] Login válido funciona
  - [X] Login inválido mostra erro adequado
  - [X] CPF com máscara funciona corretamente
  - [X] Validação de CPF funciona
  - [x] Token JWT é salvo corretamente

- [ ] **Reset de senha**
  - [x] Envio de email funciona
  - [x] Link de reset funciona
  - [x] Nova senha é aceita

- [ ] **Alteração de senha**
  - [ ] Usuário logado consegue alterar senha
  - [ ] Validação de senha atual funciona 
  - [ ] Nova senha precisa atender critérios

- [ ] **Refresh Token**
  - [ ] Token expirado é renovado automaticamente 
  - [ ] Logout funciona quando refresh falha
  - [ ] Sessão persiste após reiniciar app

- [ ] **Logout**
  - [ ] Logout limpa tokens
  - [ ] Não permite acesso após logout
  - [ ] Redireciona para login

### 2. Dashboard
- [ ] **Carregamento inicial**
  - [X] Dashboard carrega dados corretamente
  - [X] Mostra loading enquanto carrega
  - [X] Trata erro de conexão

- [ ] **Cards de acesso rápido**
  - [X] Todos os cards navegam corretamente
  - [X] Ícones estão visíveis
  - [X] Layout responsivo

- [ ] **Estatísticas**
  - [ ] Estatísticas são exibidas corretamente
  - [ ] Valores numéricos estão corretos
  - [ ] Gráficos/reportes funcionam (se houver)

- [ ] **Próximos agendamentos**
  - [ ] Lista mostra agendamentos corretos
  - [ ] Formatação de data/hora está correta
  - [ ] Ordenação está correta

### 3. Agendamentos
- [ ] **Listagem**
  - [ ] Lista todos os agendamentos
  - [ ] Filtros por status funcionam
  - [ ] Filtros por data funcionam
  - [ ] Filtros por tipo funcionam
  - [ ] Pull to refresh funciona

- [ ] **Detalhes**
  - [ ] Detalhes são exibidos corretamente
  - [ ] Informações completas aparecem
  - [ ] Formatação está correta

- [ ] **Cancelamento**
  - [ ] Cancelamento funciona
  - [ ] Campo de motivo é obrigatório
  - [ ] Confirmação funciona
  - [ ] Lista atualiza após cancelamento

- [ ] **Solicitar Agendamento** ⚠️ **NOVO**
  - [ ] Formulário está completo
  - [ ] Seleção de tipo funciona
  - [ ] Seleção de especialidade funciona
  - [ ] Seleção de profissional funciona
  - [ ] Seleção de unidade funciona
  - [ ] Seleção de data/hora funciona
  - [ ] Campo observações funciona
  - [ ] Validação de campos funciona
  - [ ] Envio para API funciona
  - [ ] Feedback de sucesso/erro funciona

### 4. Carteira de Vacinação
- [ ] **Listagem**
  - [ ] Lista todas as vacinas
  - [ ] Status está correto (aplicada/pendente/atrasada)
  - [ ] Filtros funcionam

- [ ] **Detalhes**
  - [ ] Detalhes completos são exibidos
  - [ ] Datas estão corretas
  - [ ] Documentos anexos aparecem

- [ ] **PDF**
  - [ ] Geração de PDF funciona
  - [ ] PDF contém informações corretas
  - [ ] Download funciona

### 5. Documentos
- [ ] **Listagem**
  - [ ] Lista todos os documentos
  - [ ] Filtros por tipo funcionam
  - [ ] Filtros por data funcionam

- [ ] **Download**
  - [ ] Download de PDF funciona
  - [ ] Download de imagens funciona
  - [ ] Permissões de storage funcionam (Android/iOS)

### 6. Mensagens
- [ ] **Listagem**
  - [ ] Lista todas as mensagens
  - [ ] Filtros por status funcionam
  - [ ] Filtros por tipo funcionam
  - [ ] Status de lida/não lida está correto

- [ ] **Detalhes**
  - [ ] Mensagem é marcada como lida ao abrir
  - [ ] Conteúdo completo aparece
  - [ ] Formatação está correta

### 7. Notificações
- [ ] **Listagem**
  - [ ] Lista todas as notificações
  - [ ] Filtros funcionam
  - [ ] Status de lida/não lida está correto

- [ ] **Marcar como lida**
  - [ ] Funcionalidade funciona
  - [ ] Lista atualiza

- [ ] **Notificações Locais** ⚠️ **IMPORTANTE**
  - [ ] Permissão é solicitada corretamente
  - [ ] Notificações são agendadas
  - [ ] Notificações aparecem no horário correto
  - [ ] Notificações persistem após reiniciar app
  - [ ] Ao tocar, abre tela correta
  - [ ] Som e vibração funcionam

### 8. Contas a Pagar
- [ ] **Listagem**
  - [ ] Lista todas as contas
  - [ ] Filtros funcionam
  - [ ] Status está correto

- [ ] **Cobrança**
  - [ ] Geração de boleto funciona
  - [ ] Geração de PIX funciona
  - [ ] QR Code é exibido corretamente
  - [ ] QR Code pode ser lido

### 9. Perfil
- [ ] **Visualização**
  - [ ] Dados são exibidos corretamente
  - [ ] Foto do perfil aparece (se houver)

- [ ] **Edição**
  - [ ] Edição de dados funciona
  - [ ] Validação de campos funciona
  - [ ] Salvar atualiza dados

- [ ] **Upload de Foto** ⚠️ **NOVO**
  - [ ] Botão de câmera funciona
  - [ ] Botão de galeria funciona
  - [ ] Permissão de câmera é solicitada
  - [ ] Permissão de galeria é solicitada
  - [ ] Seleção de imagem funciona
  - [ ] Upload funciona
  - [ ] Loading é exibido durante upload
  - [ ] Feedback de sucesso/erro funciona
  - [ ] Foto atualizada aparece no perfil
  - [ ] Tratamento de erro funciona

### 10. Configurações
- [ ] **Alteração de senha**
  - [ ] Funcionalidade funciona
  - [ ] Validação funciona

- [ ] **Configurações de notificação**
  - [ ] Configurações são salvas
  - [ ] Configurações persistem

- [ ] **Logout**
  - [ ] Funciona corretamente

## 🟡 Testes de Interface e UX

### 11. Splash Screen ⚠️ **NOVO**
- [ ] Splash screen aparece no início
- [ ] Logo da SoulClinic aparece
- [ ] Mensagem de boas-vindas aparece
- [ ] Animação "Carregando..." funciona
- [ ] Duração é adequada (2-3 segundos)

### 12. Navegação
- [ ] Bottom navigation funciona
- [ ] Navegação entre telas funciona
- [ ] Botão voltar funciona
- [ ] Navegação não perde estado

### 13. Temas e Cores
- [ ] Cores do tenant estão corretas
- [ ] Logo aparece corretamente
- [ ] Ícones estão visíveis
- [ ] Contraste está adequado

### 14. Responsividade
- [ ] Layout funciona em diferentes tamanhos de tela
- [ ] Orientação retrato funciona
- [ ] Orientação paisagem funciona (se suportado)

### 15. Tratamento de Erros
- [ ] Erro de conexão mostra mensagem adequada
- [ ] Erro 401 (não autorizado) redireciona para login
- [ ] Erro 500 mostra mensagem genérica
- [ ] Timeout mostra mensagem adequada
- [ ] Erros são logados corretamente

### 16. Loading e Feedback
- [ ] Loading é exibido durante requisições
- [ ] Feedback de sucesso funciona
- [ ] Feedback de erro funciona
- [ ] SnackBars aparecem corretamente

## 🟢 Testes de Produção

### 17. Ambiente de Produção
- [ ] **URL de produção está correta**
  - [ ] APK debug com `--dart-define=FORCE_PRODUCTION=true` usa produção
  - [ ] APK release usa produção por padrão
  - [ ] Não aparece URL de homologação em produção

### 18. Multitenancy
- [ ] Tenant "soulclinic" está configurado
- [ ] URL de produção está correta
- [ ] Cores e logo estão corretos

### 19. Performance
- [ ] App inicia rapidamente
- [ ] Telas carregam sem travamentos
- [ ] Scroll é fluido
- [ ] Imagens carregam otimizadamente
- [ ] Não há memory leaks aparentes

### 20. Permissões (Android)
- [ ] Permissão de internet (sempre permitida)
- [ ] Permissão de câmera é solicitada quando necessário
- [ ] Permissão de galeria é solicitada quando necessário
- [ ] Permissão de notificações (Android 13+) é solicitada
- [ ] Permissão de storage funciona corretamente

### 21. Permissões (iOS)
- [ ] Permissão de câmera é solicitada quando necessário
- [ ] Permissão de galeria é solicitada quando necessário
- [ ] Mensagens de permissão estão claras

### 22. Notificações Locais
- [ ] Permissão é solicitada no primeiro uso
- [ ] Notificações são agendadas corretamente
- [ ] Notificações aparecem no horário
- [ ] Notificações persistem após reiniciar app
- [ ] Ao tocar, abre tela correta

### 23. Armazenamento Local
- [ ] Tokens são salvos corretamente
- [ ] Dados persistem após fechar app
- [ ] Dados persistem após reiniciar app
- [ ] Logout limpa dados corretamente

## 📱 Testes em Dispositivos Reais

### 24. Android
- [ ] Testar em Android 10 ou inferior
- [ ] Testar em Android 11
- [ ] Testar em Android 12
- [ ] Testar em Android 13+
- [ ] Testar em diferentes tamanhos de tela
- [ ] Testar em modo claro
- [ ] Testar em modo escuro (se implementado)

### 25. iOS (se aplicável)
- [ ] Testar em iOS 14+
- [ ] Testar em diferentes modelos de iPhone
- [ ] Testar em iPad (se suportado)

### 26. Conectividade
- [ ] Funciona com WiFi
- [ ] Funciona com dados móveis (4G/5G)
- [ ] Trata perda de conexão
- [ ] Reconecta automaticamente quando possível

## 🔐 Testes de Segurança

### 27. Segurança de Dados
- [ ] Tokens não são expostos em logs
- [ ] Senhas não são expostas em logs
- [ ] Dados sensíveis são criptografados (se aplicável)
- [ ] Comunicação com API usa HTTPS

### 28. Validação de Dados
- [ ] CPF é validado
- [ ] Email é validado
- [ ] Campos obrigatórios são validados
- [ ] Mensagens de erro são claras

## 📋 Testes de Conformidade

### 29. Política de Privacidade
- [ ] Política de privacidade existe
- [ ] Link para política está acessível
- [ ] Conteúdo está correto e completo

### 30. Termos de Uso
- [ ] Termos de uso existem (recomendado)
- [ ] Link para termos está acessível

## ⚠️ Funcionalidades Novas que Precisam de Teste Extra

### ⭐ Upload de Foto de Perfil
**Prioridade: ALTA** - Funcionalidade nova implementada
- Testar em Android 10-
- Testar em Android 11
- Testar em Android 12
- Testar em Android 13+
- Testar seleção de câmera
- Testar seleção de galeria
- Testar compressão de imagem
- Testar tratamento de erros

### ⭐ Solicitar Agendamento
**Prioridade: ALTA** - Funcionalidade nova implementada
- Testar todos os campos do formulário
- Testar validações
- Testar integração com API
- Testar feedback de sucesso/erro
- Testar recarregamento de lista após solicitação

### ⭐ Splash Screen
**Prioridade: MÉDIA** - Funcionalidade nova implementada
- Testar duração
- Testar animação
- Testar transição para login/dashboard

## 📝 Observações

1. **Testes prioritários:** Marque os itens mais críticos primeiro
2. **Dispositivos:** Teste em pelo menos 2 dispositivos Android diferentes
3. **Versões:** Teste em pelo menos 2 versões diferentes do Android
4. **Documentação:** Anote problemas encontrados para correção

---

**Última atualização:** $(date)
**Status:** Em desenvolvimento - Testes pendentes

