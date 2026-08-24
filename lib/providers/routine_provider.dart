import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/routine.dart';
import '../utils/formatters.dart';

class RoutineProvider extends ChangeNotifier {
  List<Routine> _routines = [];
  bool _isLoading = true;

  List<Routine> get routines => _routines;
  bool get isLoading => _isLoading;

  RoutineProvider() {
    loadRoutines();
  }

  Future<void> loadRoutines() async {
    _isLoading = true;
    notifyListeners();

    final list = await DBHelper.instance.getRoutines();
    final today = Formatters.todayString();

    // Re-verify completion state relative to today's date
    _routines = list.map((routine) {
      final isDoneToday = routine.lastCompletedDate == today;
      if (routine.isCompleted != isDoneToday) {
        return routine.copyWith(isCompleted: isDoneToday);
      }
      return routine;
    }).toList();

    _isLoading = false;
    notifyListeners();
  }

  List<Routine> get morningRoutines =>
      _routines.where((r) => r.routineType == 'morning').toList();

  List<Routine> get afternoonRoutines =>
      _routines.where((r) => r.routineType == 'afternoon').toList();

  List<Routine> get eveningRoutines =>
      _routines.where((r) => r.routineType == 'evening').toList();

  List<Routine> get timelineRoutines {
    final copy = List<Routine>.from(_routines);
    copy.sort((a, b) => a.time.compareTo(b.time));
    return copy;
  }

  int get completedCount => _routines.where((r) => r.isCompleted).length;
  int get totalCount => _routines.length;
  double get completionProgress =>
      totalCount == 0 ? 0.0 : (completedCount / totalCount);

  Future<void> toggleRoutine(String id) async {
    final index = _routines.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final routine = _routines[index];
    final today = Formatters.todayString();
    final isNowDone = !routine.isCompleted;

    int newStreak = routine.streak;
    String? newLastDate;

    if (isNowDone) {
      newLastDate = today;
      newStreak = routine.streak + 1;
    } else {
      newLastDate = null;
      newStreak = routine.streak > 0 ? routine.streak - 1 : 0;
    }

    final updated = routine.copyWith(
      isCompleted: isNowDone,
      streak: newStreak,
      lastCompletedDate: newLastDate,
    );

    _routines[index] = updated;
    notifyListeners();

    await DBHelper.instance.updateRoutine(updated);
  }

  Future<void> addRoutine(Routine routine) async {
    _routines.add(routine);
    _routines.sort((a, b) => a.time.compareTo(b.time));
    notifyListeners();
    await DBHelper.instance.insertRoutine(routine);
  }

  Future<void> updateRoutine(Routine routine) async {
    final index = _routines.indexWhere((r) => r.id == routine.id);
    if (index != -1) {
      _routines[index] = routine;
      _routines.sort((a, b) => a.time.compareTo(b.time));
      notifyListeners();
      await DBHelper.instance.updateRoutine(routine);
    }
  }

  Future<void> deleteRoutine(String id) async {
    _routines.removeWhere((r) => r.id == id);
    notifyListeners();
    await DBHelper.instance.deleteRoutine(id);
  }
}
