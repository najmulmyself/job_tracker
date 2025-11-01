import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Initialize notifications
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navigate to specific screen based on payload
    print('Notification tapped: ${response.payload}');
  }

  // Request permissions (iOS)
  Future<bool> requestPermissions() async {
    final bool? result = await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return result ?? false;
  }

  // Schedule deadline reminder
  Future<void> scheduleDeadlineReminder({
    required int id,
    required String companyName,
    required String jobTitle,
    required DateTime deadline,
  }) async {
    // Schedule notification 1 day before deadline
    final scheduledDate = deadline.subtract(const Duration(days: 1));

    if (scheduledDate.isBefore(DateTime.now())) {
      // If deadline is less than 1 day away, schedule for 1 hour before
      final alternateDate = deadline.subtract(const Duration(hours: 1));
      if (alternateDate.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: id,
          title: 'Application Deadline Soon!',
          body:
              'Your application for $jobTitle at $companyName is due in 1 hour.',
          scheduledDate: alternateDate,
          payload: 'deadline_$id',
        );
      }
      return;
    }

    await _scheduleNotification(
      id: id,
      title: 'Application Deadline Tomorrow',
      body: 'Don\'t forget: $jobTitle at $companyName is due tomorrow!',
      scheduledDate: scheduledDate,
      payload: 'deadline_$id',
    );
  }

  // Schedule draft reminder
  Future<void> scheduleDraftReminder({required int draftCount}) async {
    // Schedule daily reminder at 9 AM
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 9, 0);

    // If 9 AM has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _scheduleNotification(
      id: 999, // Fixed ID for draft reminder
      title: 'Pending Applications',
      body: 'You have $draftCount draft applications waiting to be completed.',
      scheduledDate: scheduledDate,
      payload: 'drafts',
    );
  }

  // Schedule interview reminders
  Future<void> scheduleInterviewReminders({
    required String jobId,
    required String companyName,
    required String jobTitle,
    required DateTime interviewDateTime,
  }) async {
    if (!_initialized) await initialize();

    // Cancel any existing notifications for this job
    await cancelInterviewReminders(jobId);

    final now = DateTime.now();

    // Don't schedule if interview is in the past
    if (interviewDateTime.isBefore(now)) return;

    // Schedule notification on interview day (at 9 AM)
    final onInterviewDay = DateTime(
      interviewDateTime.year,
      interviewDateTime.month,
      interviewDateTime.day,
      9, // 9 AM on interview day
      0,
    );

    if (onInterviewDay.isAfter(now)) {
      await _scheduleNotification(
        id: '${jobId}_day'.hashCode,
        title: 'Interview Today! 🎯',
        body: 'You have an interview with $companyName for $jobTitle',
        scheduledDate: onInterviewDay,
        payload: 'interview_$jobId',
      );
    }

    // Schedule notification 30 minutes before interview
    final thirtyMinsBefore = interviewDateTime.subtract(
      const Duration(minutes: 30),
    );

    if (thirtyMinsBefore.isAfter(now)) {
      await _scheduleNotification(
        id: '${jobId}_30min'.hashCode,
        title: 'Interview in 30 Minutes! ⏰',
        body: 'Get ready for your interview with $companyName',
        scheduledDate: thirtyMinsBefore,
        payload: 'interview_$jobId',
      );
    }
  }

  // Cancel interview reminders for a specific job
  Future<void> cancelInterviewReminders(String jobId) async {
    if (!_initialized) await initialize();

    // Cancel both notifications for this job
    await _notifications.cancel('${jobId}_day'.hashCode);
    await _notifications.cancel('${jobId}_30min'.hashCode);
  }

  // Generic schedule notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'job_tracker_channel',
          'Job Tracker Notifications',
          channelDescription:
              'Notifications for job application deadlines and reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'job_tracker_channel',
          'Job Tracker Notifications',
          channelDescription:
              'Notifications for job application deadlines and reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
