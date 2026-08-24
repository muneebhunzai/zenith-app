import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/prayer_reminder.dart';
import '../services/notification_service.dart';
import '../utils/formatters.dart';

class PrayerProvider extends ChangeNotifier {
  List<PrayerReminder> _prayers = [];
  bool _isLoading = true;

  List<PrayerReminder> get prayers => _prayers;
  bool get isLoading => _isLoading;

  PrayerProvider() {
    loadPrayers();
  }

  Future<void> loadPrayers() async {
    _isLoading = true;
    notifyListeners();

    final list = await DBHelper.instance.getPrayers();
    final today = Formatters.todayString();

    _prayers = list.map((prayer) {
      final isDoneToday = prayer.lastCompletedDate == today;
      if (prayer.isCompletedToday != isDoneToday) {
        return prayer.copyWith(isCompletedToday: isDoneToday);
      }
      return prayer;
    }).toList();

    _isLoading = false;
    notifyListeners();

    _scheduleAllActiveNotifications();
  }

  int get completedCount => _prayers.where((p) => p.isCompletedToday).length;
  int get totalCount => _prayers.length;
  double get completionProgress => totalCount == 0 ? 0.0 : (completedCount / totalCount);

  Future<void> togglePrayerCompleted(String id) async {
    final index = _prayers.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final prayer = _prayers[index];
    final today = Formatters.todayString();
    final isDone = !prayer.isCompletedToday;

    final updated = prayer.copyWith(
      isCompletedToday: isDone,
      lastCompletedDate: isDone ? today : null,
    );

    _prayers[index] = updated;
    notifyListeners();

    await DBHelper.instance.updatePrayer(updated);
  }

  Future<void> togglePrayerEnabled(String id) async {
    final index = _prayers.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final prayer = _prayers[index];
    final updated = prayer.copyWith(isEnabled: !prayer.isEnabled);

    _prayers[index] = updated;
    notifyListeners();

    await DBHelper.instance.updatePrayer(updated);

    if (updated.isEnabled) {
      _scheduleNotification(updated);
    } else {
      _cancelNotification(updated);
    }
  }

  Future<void> updateScheduledTime(String id, String newTime) async {
    final index = _prayers.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final prayer = _prayers[index];
    final updated = prayer.copyWith(scheduledTime: newTime);

    _prayers[index] = updated;
    notifyListeners();

    await DBHelper.instance.updatePrayer(updated);

    if (updated.isEnabled) {
      _scheduleNotification(updated);
    }
  }

  void _scheduleAllActiveNotifications() {
    for (var prayer in _prayers) {
      if (prayer.isEnabled) {
        _scheduleNotification(prayer);
      }
    }
  }

  void _scheduleNotification(PrayerReminder prayer) {
    try {
      final parts = prayer.scheduledTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final int notifId = prayer.id.hashCode;

      NotificationService.instance.scheduleDailyReminder(
        id: notifId,
        title: prayer.name,
        body: 'Time for ${prayer.name}. Take a moment to pause and reflect.',
        hour: hour,
        minute: minute,
      );
    } catch (_) {}
  }

  void _cancelNotification(PrayerReminder prayer) {
    NotificationService.instance.cancelReminder(prayer.id.hashCode);
  }
}
