# Configurações Faltantes no App

Este documento lista todas as configurações que foram implementadas e as que ainda precisam ser configuradas manualmente.

## ✅ Configurações Implementadas

### 1. Permissões Android (AndroidManifest.xml)
- ✅ `INTERNET` - Para requisições HTTP
- ✅ `CAMERA` - Para tirar fotos do perfil
- ✅ `READ_EXTERNAL_STORAGE` - Para ler arquivos (Android ≤ 12)
- ✅ `WRITE_EXTERNAL_STORAGE` - Para salvar arquivos (Android ≤ 12)
- ✅ `READ_MEDIA_IMAGES` - Para ler imagens (Android 13+)
- ✅ `READ_MEDIA_VIDEO` - Para ler vídeos (Android 13+)
- ✅ `POST_NOTIFICATIONS` - Para notificações (Android 13+)
- ✅ `VIBRATE` - Para vibrar em notificações
- ✅ `RECEIVE_BOOT_COMPLETED` - Para agendar notificações após reiniciar
- ✅ `SCHEDULE_EXACT_ALARM` - Para agendar notificações exatas

### 2. Configurações de Notificações Android
- ✅ Receivers para notificações locais configurados
- ✅ `ScheduledNotificationBootReceiver` - Para notificações após reiniciar
- ✅ `ScheduledNotificationReceiver` - Para notificações agendadas

### 3. Permissões iOS (Info.plist)
- ✅ `NSCameraUsageDescription` - Permissão para usar a câmera
- ✅ `NSPhotoLibraryUsageDescription` - Permissão para acessar galeria
- ✅ `NSPhotoLibraryAddUsageDescription` - Permissão para salvar fotos
- ✅ `UIBackgroundModes` - Modo de background para notificações remotas

### 4. Inicializações no main.dart
- ✅ Inicialização do Hive (banco de dados local)
- ✅ Inicialização das notificações locais
- ✅ WidgetsFlutterBinding.ensureInitialized()

### 5. Serviço de Notificações
- ✅ `NotificationService` criado com métodos para:
  - Inicializar notificações
  - Mostrar notificações
  - Agendar notificações
  - Cancelar notificações
  - Verificar permissões

### 6. Nome do App
- ✅ Android: Label alterado para "Portal do Paciente"
- ✅ iOS: Display Name alterado para "Portal Paciente App"

### 7. Application ID / Package Name
- ✅ Android: `com.soulclinic.portal_paciente_app` configurado

## ⚠️ Configurações que Ainda Precisam ser Feitas Manualmente

### 1. Assinatura de Produção Android (CRÍTICO)
**Localização:** `android/app/build.gradle.kts`

**Status:** ✅ **CONFIGURADO** - Pronto para uso quando o keystore for criado

**Próximos passos (AÇÃO MANUAL NECESSÁRIA):**

1. **Criar um keystore para produção:**
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   **⚠️ IMPORTANTE:** Guarde as senhas e o arquivo em local seguro!

2. **Criar arquivo `android/key.properties`:**
   - Copie `android/key.properties.example` para `android/key.properties`
   - Preencha com seus dados reais:
   ```properties
   storePassword=SUA_SENHA_DO_KEYSTORE
   keyPassword=SUA_SENHA_DA_CHAVE
   keyAlias=upload
   storeFile=/caminho/completo/para/upload-keystore.jks
   ```

3. ✅ **`android/app/build.gradle.kts` já configurado:**
   ```kotlin
   android {
       // ... outras configurações
       
       signingConfigs {
           create("release") {
               val keystorePropertiesFile = rootProject.file("key.properties")
               val keystoreProperties = Properties()
               if (keystorePropertiesFile.exists()) {
                   keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                   storeFile = file(keystoreProperties["storeFile"] as String)
                   storePassword = keystoreProperties["storePassword"] as String
                   keyAlias = keystoreProperties["keyAlias"] as String
                   keyPassword = keystoreProperties["keyPassword"] as String
               }
           }
       }
       
       buildTypes {
           release {
               signingConfig = signingConfigs.getByName("release")
               // ... outras configurações
           }
       }
   }
   ```

**⚠️ IMPORTANTE:** 
- NUNCA commite o arquivo `key.properties` ou o keystore no Git
- Adicione `android/key.properties` e `*.jks` ao `.gitignore`
- Guarde o keystore em local seguro (perda = impossível de atualizar o app na Play Store)

**4. ✅ `.gitignore` atualizado:**
   O arquivo `.gitignore` já está configurado para ignorar arquivos de keystore

**5. ✅ Arquivo de exemplo criado:**
   Criado `android/key.properties.example` como modelo

### 2. Bundle Identifier iOS
**Localização:** `ios/Runner.xcodeproj/project.pbxproj` e `ios/Runner/Info.plist`

**Status:** Usando variável `$(PRODUCT_BUNDLE_IDENTIFIER)` - precisa ser configurado

**O que fazer:**
1. Abrir o projeto no Xcode
2. Selecionar o target "Runner"
3. Ir em "Signing & Capabilities"
4. Alterar o Bundle Identifier para algo único (ex: `com.soulclinic.portalPacienteApp`)
5. Configurar o Team/Apple Developer Account
6. **Importante:** O Bundle Identifier deve ser único e corresponder ao Application ID do Android quando possível

### 3. App Icons e Splash Screen
**Status:** Usando ícones padrão do Flutter

**O que fazer:**
1. Gerar ícones personalizados:
   - Android: Substituir arquivos em `android/app/src/main/res/mipmap-*/`
   - iOS: Substituir em `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

2. Configurar splash screen personalizado (opcional)

### 4. Firebase/OneSignal para Push Notifications (Opcional)
**Status:** Apenas notificações locais implementadas

**O que fazer (se necessário):**
1. Adicionar dependências no `pubspec.yaml`:
   ```yaml
   firebase_core: ^2.24.0
   firebase_messaging: ^14.7.0
   # OU
   onesignal_flutter: ^5.0.0
   ```

2. Configurar Firebase Console ou OneSignal
3. Adicionar arquivos de configuração:
   - Android: `google-services.json`
   - iOS: `GoogleService-Info.plist`

### 5. Configuração de URLs de Produção
**Localização:** `lib/config/app_config.dart`

**Status:** ✅ URLs configuradas e sistema de multitenancy implementado

**URLs Configuradas:**
- **Produção (SoulClinic):** `https://production.soulclinic.com.br/api/portal` ✅ Testada e funcionando
- **Homologação:** `http://127.0.0.1:8080/api/portal`
- **Tenant Default:** `soulclinic` configurado

**Características Implementadas:**
- ✅ Sistema de multitenancy configurado
- ✅ Suporte para múltiplos tenants (SoulClinic e Clínica Exemplo)
- ✅ Detecção automática de ambiente (Debug/Release)
- ✅ Configuração dinâmica de URLs por tenant

**Observações:**
- A API de produção foi testada e está funcionando corretamente
- As URLs estão corretas conforme os testes realizados
- O sistema permite adicionar novos tenants facilmente

### 6. Configuração de Timeout e Retry
**Localização:** `lib/config/app_config.dart` e `lib/services/api_service.dart`

**Status:** ✅ Configurado e implementado

**Configurações Atuais:**
- ✅ Timeout de requisição: 30 segundos
- ✅ Máximo de tentativas: 3
- ✅ Interceptadores configurados para refresh automático de token
- ✅ Tratamento de erros 401 (token expirado) com renovação automática

**Implementações Adicionais:**
- ✅ Sistema de refresh token implementado
- ✅ Tratamento de erros HTTP completo
- ✅ Logs detalhados para debug
- ✅ Suporte a múltiplas tentativas de requisição

**O que fazer (se necessário):**
Ajustar valores em `app_config.dart`:
```dart
static const int requestTimeoutSeconds = 30;
static const int maxRetryAttempts = 3;
```

### 8. Assets (Imagens e Ícones)
**Localização:** `assets/images/` e `assets/icons/`

**Status:** ✅ **CONFIGURADO**

**Arquivos Adicionados:**
1. ✅ Logo da SoulClinic: `assets/images/soulclinic_logo.png`
2. ✅ Ícones do Android: `android/app/src/main/res/mipmap-*/ic_launcher.png` (todos os tamanhos)
3. ✅ Ícones do iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (todos os tamanhos)
4. ✅ Ícones extras: `assets/icons/appstore.png` e `assets/icons/playstore.png`

**Observações:**
- Logo da SoulClinic está sendo carregado corretamente na tela de login
- Ícones do app estão configurados para Android e iOS
- O código trata corretamente quando o logo não existe (mostra ícone padrão)

### 9. Configuração de Analytics e Crashlytics (Opcional)
**Status:** Não configurado

**O que fazer (se necessário):**
1. Adicionar dependências:
   ```yaml
   firebase_analytics: ^10.7.0
   firebase_crashlytics: ^3.4.9
   ```

2. Configurar no Firebase Console

### 10. Testes e Validação
**Status:** Estrutura básica criada

**O que fazer:**
1. Testar todas as funcionalidades em dispositivos reais
2. Testar em diferentes versões de Android/iOS
3. Validar permissões em dispositivos reais
4. Testar notificações locais
5. Testar upload de imagens

## 📝 Checklist Final

Antes de publicar na Play Store / App Store:

- [ ] Keystore de produção configurado e seguro
- [ ] Arquivo `android/key.properties` criado com dados reais
- [ ] Bundle Identifier iOS configurado e único
- [ ] Team/Apple Developer Account configurado no Xcode
- [x] Ícones personalizados adicionados (Android e iOS) ✅
- [x] Logo da SoulClinic adicionado ✅
- [ ] Splash screen personalizado (opcional)
- [ ] URLs de produção verificadas e testadas
- [ ] Testes realizados em dispositivos reais (Android e iOS)
- [ ] Notificações locais testadas e funcionando
- [ ] Permissões testadas em dispositivos reais
- [ ] Upload de imagens testado e funcionando
- [ ] Sistema de autenticação testado completamente
- [ ] Refresh token testado e funcionando
- [ ] Multitenancy testado (se aplicável)
- [ ] Analytics configurado (se necessário)
- [ ] Crashlytics configurado (se necessário)
- [ ] Firebase/OneSignal configurado (se necessário para push notifications)
- [ ] Documentação atualizada
- [ ] Política de privacidade criada (obrigatório para publicação)
- [ ] Termos de uso criados (recomendado)

## 🔐 Segurança

**IMPORTANTE - NUNCA commite no Git:**
- Arquivos de keystore (`*.jks`, `*.keystore`)
- Arquivo `android/key.properties` (já configurado no `.gitignore`)
- Arquivos de configuração do Firebase (`google-services.json`, `GoogleService-Info.plist`)
- Arquivos `.env` com credenciais
- Certificados e chaves privadas (`*.p12`, `*.pem`, `*.key`, `*.crt`)
- Tokens de acesso e refresh tokens
- Senhas e credenciais de API

**Status do `.gitignore`:**
- ✅ Configurado para ignorar keystores (`*.jks`, `*.keystore`)
- ✅ Configurado para ignorar `android/key.properties`
- ✅ Configurado para ignorar arquivos `.env`
- ✅ Configurado para ignorar certificados e chaves
- ✅ Mantém `android/key.properties.example` (arquivo de exemplo seguro)

## 📞 Suporte

Se tiver dúvidas sobre alguma configuração, consulte:
- Documentação do Flutter: https://flutter.dev/docs
- Documentação da Play Store: https://developer.android.com/distribute
- Documentação da App Store: https://developer.apple.com/app-store

---

**Última atualização:** 02/11/2025  
**Status:** Configurações básicas implementadas ✅

---

## 📋 Resumo das Configurações Prioritárias

### 🔴 Crítico (Fazer antes de publicar):
1. ⚠️ Criar keystore de produção e configurar `key.properties`
2. ⚠️ Bundle Identifier iOS configurado no Xcode
3. ✅ Assinatura de Produção Android (configurado, aguardando keystore)
4. ✅ `.gitignore` configurado corretamente

### 🟡 Importante (Recomendado):
5. ✅ App Icons personalizados (Android e iOS)
6. ⚠️ Splash screen personalizado (opcional)
7. ✅ URLs de Produção verificadas e testadas
8. ⚠️ Testes completos em dispositivos reais
9. ✅ Sistema de notificações locais implementado
10. ✅ Logo da SoulClinic configurado

### 🟢 Opcional (Melhorias Futuras):
11. ⚠️ Firebase/OneSignal para Push Notifications remotas
12. ⚠️ Analytics e Crashlytics
13. ⚠️ Assets personalizados (logos adicionais das clínicas)
14. ⚠️ Política de Privacidade e Termos de Uso

