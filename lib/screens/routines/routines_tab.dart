import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routine.dart';
import '../../models/prayer_reminder.dart';
import '../../providers/routine_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import 'add_routine_dialog.dart';

class RoutinesTab extends StatelessWidget {
  const RoutinesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Schedule & Habits'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
            tabs: [
              Tab(icon: Icon(Icons.view_timeline_rounded), text: 'Timeline'),
              Tab(icon: Icon(Icons.checklist_rounded), text: 'Checklists'),
              Tab(icon: Icon(Icons.local_fire_department_rounded), text: 'Habits'),
              Tab(icon: Icon(Icons.access_alarms_rounded), text: 'Reflections & Prayers'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TimelineView(),
            _ChecklistsView(),
            _HabitsView(),
            _PrayersView(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'fab_routines_tab',
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => const AddRoutineDialog(),
            );
          },
          child: const Icon(Icons.add_task_rounded),
        ),
      ),
    );
  }
}

// 1. VISUAL DAILY TIMELINE
class _TimelineView extends StatelessWidget {
  const _TimelineView();

  @override
  Widget build(BuildContext context) {
    final routineProvider = Provider.of<RoutineProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final routines = routineProvider.timelineRoutines;

    if (routines.isEmpty) {
      return _buildEmptyState(isDark, 'No scheduled routines', 'Tap + to add a time block');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: routines.length,
      itemBuilder: (context, index) {
        final routine = routines[index];
        final isLast = index == routines.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Label
              SizedBox(
                width: 65,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    Formatters.formatTime24to12(routine.time),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                ),
              ),

              // Timeline Line & Dot Indicator
              Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: routine.isCompleted
                          ? AppTheme.primaryColor
                          : (isDark ? AppTheme.darkCard : Colors.white),
                      border: Border.all(
                        color: routine.isCompleted ? AppTheme.primaryColor : Colors.grey,
                        width: 2.5,
                      ),
                    ),
                    child: routine.isCompleted
                        ? const Icon(Icons.check, size: 10, color: Colors.white)
                        : null,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Card Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: InkWell(
                    onTap: () => routineProvider.toggleRoutine(routine.id),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: routine.isCompleted
                              ? AppTheme.primaryColor.withOpacity(0.5)
                              : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  routine.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    decoration: routine.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: routine.isCompleted
                                        ? (isDark ? Colors.white38 : Colors.black38)
                                        : null,
                                  ),
                                ),
                              ),
                              _buildPriorityBadge(routine.priority),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.repeat_rounded,
                                size: 14,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                routine.routineType.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                ),
                              ),
                              if (routine.streak > 0) ...[
                                const SizedBox(width: 12),
                                Text(
                                  '🔥 ${routine.streak} streak',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.accentOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              const Spacer(),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.grey),
                                onPressed: () => routineProvider.deleteRoutine(routine.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 2. CHECKLISTS VIEW (Morning, Afternoon, Evening)
class _ChecklistsView extends StatelessWidget {
  const _ChecklistsView();

  @override
  Widget build(BuildContext context) {
    final routineProvider = Provider.of<RoutineProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final morning = routineProvider.morningRoutines;
    final afternoon = routineProvider.afternoonRoutines;
    final evening = routineProvider.eveningRoutines;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(context, '🌅 Morning Routine', morning, routineProvider, isDark),
        const SizedBox(height: 20),
        _buildSection(context, '☀️ Afternoon Routine', afternoon, routineProvider, isDark),
        const SizedBox(height: 20),
        _buildSection(context, '🌙 Evening Routine', evening, routineProvider, isDark),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Routine> list,
    RoutineProvider provider,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${list.where((r) => r.isCompleted).length}/${list.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No routines added for this block.',
                style: TextStyle(
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  fontSize: 13,
                ),
              ),
            )
          else
            ...list.map((routine) {
              return CheckboxListTile(
                value: routine.isCompleted,
                onChanged: (_) => provider.toggleRoutine(routine.id),
                activeColor: AppTheme.primaryColor,
                title: Text(
                  routine.title,
                  style: TextStyle(
                    fontSize: 14,
                    decoration: routine.isCompleted ? TextDecoration.lineThrough : null,
                    color: routine.isCompleted
                        ? (isDark ? Colors.white38 : Colors.black38)
                        : null,
                  ),
                ),
                subtitle: Text(
                  Formatters.formatTime24to12(routine.time),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
                secondary: _buildPriorityBadge(routine.priority),
              );
            }),
        ],
      ),
    );
  }
}

// 3. HABIT TRACKER & STREAKS
class _HabitsView extends StatelessWidget {
  const _HabitsView();

  @override
  Widget build(BuildContext context) {
    final routineProvider = Provider.of<RoutineProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final routines = routineProvider.routines;

    if (routines.isEmpty) {
      return _buildEmptyState(isDark, 'No habits registered', 'Add a routine or habit to start tracking streaks');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: routines.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final habit = routines[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: habit.isCompleted
                  ? AppTheme.primaryColor.withOpacity(0.5)
                  : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('🔥', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          '${habit.streak} day streak',
                          style: const TextStyle(
                            color: AppTheme.accentOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      habit.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: habit.isCompleted ? AppTheme.primaryColor : Colors.grey,
                      size: 28,
                    ),
                    onPressed: () => routineProvider.toggleRoutine(habit.id),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              // Weekly progress bubbles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  final isDone = habit.isCompleted && i == DateTime.now().weekday - 1;
                  return Column(
                    children: [
                      Text(
                        days[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? AppTheme.primaryColor
                              : (isDark ? AppTheme.darkCard : Colors.grey.shade200),
                        ),
                        child: isDone
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 4. PRAYERS & REFLECTION VIEW
class _PrayersView extends StatelessWidget {
  const _PrayersView();

  @override
  Widget build(BuildContext context) {
    final prayerProvider = Provider.of<PrayerProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayers = prayerProvider.prayers;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Daily Progress Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF065F46), Color(0xFF047857)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Reflections & Prayers',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Completed ${prayerProvider.completedCount} of ${prayerProvider.totalCount} today',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: prayerProvider.completionProgress,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.nights_stay_rounded, size: 42, color: Colors.white),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Prayers List
        ...prayers.map((prayer) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: prayer.isCompletedToday
                    ? AppTheme.primaryColor.withOpacity(0.5)
                    : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: InkWell(
                onTap: () => prayerProvider.togglePrayerCompleted(prayer.id),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: prayer.isCompletedToday
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                    border: Border.all(
                      color: prayer.isCompletedToday ? AppTheme.primaryColor : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: prayer.isCompletedToday
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              ),
              title: Text(
                prayer.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  decoration: prayer.isCompletedToday ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: InkWell(
                onTap: () async {
                  final parts = prayer.scheduledTime.split(':');
                  final initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
                  final picked = await showTimePicker(context: context, initialTime: initial);
                  if (picked != null) {
                    final h = picked.hour.toString().padLeft(2, '0');
                    final m = picked.minute.toString().padLeft(2, '0');
                    prayerProvider.updateScheduledTime(prayer.id, '$h:$m');
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Formatters.formatTime24to12(prayer.scheduledTime),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit, size: 12, color: AppTheme.primaryColor),
                  ],
                ),
              ),
              trailing: Switch(
                value: prayer.isEnabled,
                activeColor: AppTheme.primaryColor,
                onChanged: (_) => prayerProvider.togglePrayerEnabled(prayer.id),
              ),
            );
          });
      ],
    );
  }
}

Widget _buildPriorityBadge(String priority) {
  Color color;
  switch (priority.toLowerCase()) {
    case 'high':
      color = AppTheme.accentRed;
      break;
    case 'medium':
      color = AppTheme.accentOrange;
      break;
    default:
      color = AppTheme.primaryColor;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      priority.toUpperCase(),
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildEmptyState(bool isDark, String title, String subtitle) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.schedule_rounded, size: 54, color: isDark ? Colors.white24 : Colors.black12),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
