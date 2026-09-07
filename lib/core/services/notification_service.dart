import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  final actionId = notificationResponse.actionId;
  if (actionId != null && actionId.isNotEmpty) {
    NotificationService().handleAction(actionId);
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  void Function(String actionId)? onActionReceived;

  void handleAction(String actionId) {
    onActionReceived?.call(actionId);
  }

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final actionId = response.actionId;
          if (actionId != null && actionId.isNotEmpty) {
            handleAction(actionId);
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      final launchDetails =
          await _notificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails != null &&
          launchDetails.didNotificationLaunchApp &&
          launchDetails.notificationResponse != null) {
        final actionId = launchDetails.notificationResponse!.actionId;
        if (actionId != null && actionId.isNotEmpty) {
          Future.microtask(() => handleAction(actionId));
        }
      }

      _initialized = true;
    } catch (e) {
      // In test environments without platform channels initialized
      _initialized = false;
    }
  }

  Future<void> updateGpsNotification({
    required bool isTracking,
    required bool isPaused,
    required double distanceKm,
    required double speedKmH,
  }) async {
    try {
      if (!_initialized) await initialize();
      if (!_initialized) return;

      if (!isTracking && !isPaused) {
        await _notificationsPlugin.cancel(1001);
        return;
      }

      final paceString = _calculatePace(speedKmH);
      final distanceStr = distanceKm.toStringAsFixed(2);
      final title = isTracking ? '🟢 GPS Run Active' : '⏸️ GPS Run Paused';
      final summaryBody = '$distanceStr km  •  $paceString  •  ${speedKmH.toStringAsFixed(1)} km/h';
      final bigTextBody =
          '📍 Distance: $distanceStr km\n⚡ Pace: $paceString\n🚀 Speed: ${speedKmH.toStringAsFixed(1)} km/h';

      final List<AndroidNotificationAction> actions = [];
      if (isTracking) {
        actions.add(
          const AndroidNotificationAction(
            'gps_pause',
            'Pause',
            showsUserInterface: true,
          ),
        );
      } else if (isPaused) {
        actions.add(
          const AndroidNotificationAction(
            'gps_resume',
            'Resume',
            showsUserInterface: true,
          ),
        );
      }

      actions.add(
        const AndroidNotificationAction(
          'gps_stop',
          'Stop',
          showsUserInterface: true,
        ),
      );

      final androidDetails = AndroidNotificationDetails(
        'gps_tracking_channel',
        'GPS Tracking',
        channelDescription: 'Notifications for ongoing GPS tracking and control',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        subText: 'Cadence Run Tracker',
        category: AndroidNotificationCategory.workout,
        styleInformation: BigTextStyleInformation(
          bigTextBody,
          contentTitle: title,
          summaryText: 'Run Metrics',
        ),
        actions: actions,
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        1001,
        title,
        summaryBody,
        notificationDetails,
      );
    } catch (_) {
      // Ignore errors when platform channel is not available (e.g. unit tests)
    }
  }

  Future<void> updateMetronomeNotification({
    required bool isRunning,
    required int cadence,
  }) async {
    try {
      if (!_initialized) await initialize();
      if (!_initialized) return;

      if (!isRunning) {
        await _notificationsPlugin.cancel(1002);
        return;
      }

      const title = '🎵 Metronome Active';
      final body = 'Target Cadence: $cadence SPM';

      final actions = [
        const AndroidNotificationAction(
          'metronome_stop',
          'Stop',
          showsUserInterface: true,
        ),
      ];

      final androidDetails = AndroidNotificationDetails(
        'metronome_channel',
        'Metronome Controls',
        channelDescription: 'Notifications for Metronome playback control',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        subText: 'Cadence Audio',
        category: AndroidNotificationCategory.service,
        actions: actions,
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        1002,
        title,
        body,
        notificationDetails,
      );
    } catch (_) {
      // Ignore errors when platform channel is not available (e.g. unit tests)
    }
  }

  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (_) {}
  }

  String _calculatePace(double speedKmH) {
    if (speedKmH <= 0.1) return "--'--\"/km";
    final paceDecimalMinutes = 60.0 / speedKmH;
    final minutes = paceDecimalMinutes.floor();
    final seconds = ((paceDecimalMinutes - minutes) * 60).round();
    final secondsStr = seconds < 10 ? '0$seconds' : '$seconds';
    return '$minutes\'$secondsStr"/km';
  }
}
