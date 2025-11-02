import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Inicializar notificações locais
  static Future<void> initialize() async {
    // Configurações Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configurações iOS
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Configurações gerais
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Inicializar plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Solicitar permissões no Android 13+
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _requestAndroidPermissions();
    }

    if (kDebugMode) {
      print('✅ Notificações locais inicializadas');
    }
  }

  /// Solicitar permissões no Android
  static Future<void> _requestAndroidPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      if (kDebugMode) {
        print('✅ Permissão de notificações solicitada (Android)');
      }
    }
  }

  /// Callback quando uma notificação é tocada
  static void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('📱 Notificação tocada: ${response.payload}');
    }
    // Aqui você pode navegar para uma tela específica baseada no payload
  }

  /// Mostrar notificação simples
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'portal_paciente_channel',
      'Portal do Paciente',
      channelDescription: 'Notificações do Portal do Paciente',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Agendar notificação
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'portal_paciente_channel',
      'Portal do Paciente',
      channelDescription: 'Notificações do Portal do Paciente',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledDate),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Converter DateTime para TZDateTime
  static dynamic _convertToTZDateTime(DateTime dateTime) {
    // Para simplificar, usando o timezone local
    // Para produção, considere usar o package timezone
    return dateTime;
  }

  /// Cancelar notificação
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancelar todas as notificações
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Verificar se as permissões foram concedidas (Android)
  static Future<bool> areNotificationsEnabled() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return true; // iOS sempre retorna true após solicitar
    }

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }

    return false;
  }
}

