import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/journal_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../journal/journal_edit_screen.dart';
import '../finances/add_transaction_dialog.dart';
import '../routines/add_routine_dialog.dart';

class DashboardTab extends StatelessWidget {
  final Function(int tabIndex) onNavigateToTab;

  const DashboardTab({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final routineProvider = Provider.of<RoutineProvider>(context);
    final financeProvider = Provider.of<FinanceProvider>(context);
    final prayerProvider = Provider.of<PrayerProvider>(context);
    final journalProvider = Provider.of<JournalProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
            ),
            Text(
              Formatters.formatShortDate(now),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Quick Stats Grid
            _buildQuickStatsRow(
              routineProvider: routineProvider,
              financeProvider: financeProvider,
              prayerProvider: prayerProvider,
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // 2. Today's Mood Selector Card
            _buildMoodCard(context, journalProvider, isDark),
            const SizedBox(height: 16),

            // 3. Today's Schedule & Routines Overview
            _buildRoutinesCard(context, routineProvider, isDark),
            const SizedBox(height: 16),

            // 4. Daily Prayer & Reflection Checklist
            _buildPrayersCard(context, prayerProvider, isDark),
            const SizedBox(height: 16),

            // 5. Financial Summary Card
            _buildFinancialCard(context, financeProvider, isDark),
            const SizedBox(height: 16),

            // 6. Quick Journal Reflection Prompt
            _buildJournalPromptCard(context, isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  Widget _buildQuickStatsRow({
    required RoutineProvider routineProvider,
    required FinanceProvider financeProvider,
    required PrayerProvider prayerProvider,
    required bool isDark,
  }) {
    return Row(
      children: [
        // Routines Stat
        Expanded(
          child: _buildMetricCard(
            title: 'Routines',
            value: '${routineProvider.completedCount}/${routineProvider.totalCount}',
            subtitle: '${(routineProvider.completionProgress * 100).toStringAsFixed(0)}% Done',
            icon: Icons.check_circle_outline_rounded,
            accentColor: AppTheme.primaryColor,
            isDark: isDark,
            onTap: () => onNavigateToTab(2),
          ),
        ),
        const SizedBox(width: 8),
        // Prayers Stat
        Expanded(
          child: _buildMetricCard(
            title: 'Prayers',
            value: '${prayerProvider.completedCount}/${prayerProvider.totalCount}',
            subtitle: 'Completed',
            icon: Icons.nights_stay_outlined,
            accentColor: AppTheme.secondaryColor,
            isDark: isDark,
            onTap: () => onNavigateToTab(2),
          ),
        ),
        const SizedBox(width: 8),
        // Balance Stat
        Expanded(
          child: _buildMetricCard(
            title: 'Balance',
            value: Formatters.formatCompactCurrency(financeProvider.netBalance),
            subtitle: 'Net Total',
            icon: Icons.account_balance_wallet_outlined,
            accentColor: financeProvider.netBalance >= 0 ? AppTheme.accentGreen : AppTheme.accentRed,
            isDark: isDark,
            onTap: () => onNavigateToTab(1),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: accentColor),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCard(BuildContext context, JournalProvider journalProvider, bool isDark) {
    final moods = ['Great', 'Good', 'Neutral', 'Low', 'Stressed'];
    final currentMood = journalProvider.todayMood;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'How are you feeling today?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                currentMood,
                style: TextStyle(
                  color: Formatters.getMoodColor(currentMood),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: moods.map((mood) {
              final isSelected = currentMood.toLowerCase() == mood.toLowerCase();
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const JournalEditScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Formatters.getMoodColor(mood).withOpacity(0.2)
                        : (isDark ? AppTheme.darkCard : Colors.grey.shade100),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Formatters.getMoodColor(mood), width: 1.5)
                        : null,
                  ),
                  child: Icon(
                    Formatters.getMoodIcon(mood),
                    color: Formatters.getMoodColor(mood),
                    size: 24,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutinesCard(BuildContext context, RoutineProvider routineProvider, bool isDark) {
    final routines = routineProvider.routines.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist_rounded, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Today's Routines & Habits",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => onNavigateToTab(2),
                child: const Text('View All', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          if (routines.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No routines scheduled today',
                  style: TextStyle(
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          else
            ...routines.map((routine) {
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: IconButton(
                  icon: Icon(
                    routine.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: routine.isCompleted ? AppTheme.primaryColor : Colors.grey,
                  ),
                  onPressed: () => routineProvider.toggleRoutine(routine.id),
                ),
                title: Text(
                  routine.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: routine.isCompleted ? TextDecoration.lineThrough : null,
                    color: routine.isCompleted ? (isDark ? Colors.white38 : Colors.black38) : null,
                  ),
                ),
                subtitle: Text(
                  Formatters.formatTime24to12(routine.time),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
                trailing: routine.streak > 0
                    ? Text('🔥 ${routine.streak}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentOrange))
                    : null,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPrayersCard(BuildContext context, PrayerProvider prayerProvider, bool isDark) {
    final prayers = prayerProvider.prayers;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_alarms_rounded, color: AppTheme.secondaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Prayers & Daily Reflection',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${prayerProvider.completedCount}/${prayerProvider.totalCount}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, fontSize: 13),
              ),
            ],
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: prayers.map((p) {
              return InkWell(
                onTap: () => prayerProvider.togglePrayerCompleted(p.id),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: p.isCompletedToday ? AppTheme.secondaryColor : Colors.transparent,
                          border: Border.all(
                            color: p.isCompletedToday ? AppTheme.secondaryColor : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: p.isCompletedToday
                            ? const Icon(Icons.check, size: 18, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.name.split(' ')[0], // First word (e.g. Fajr, Dhuhr)
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: p.isCompletedToday ? AppTheme.secondaryColor : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(BuildContext context, FinanceProvider financeProvider, bool isDark) {
    return InkWell(
      onTap: () => onNavigateToTab(1),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart_outline_rounded, color: AppTheme.accentOrange, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Monthly Spending & Budget',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: financeProvider.budgetSpentPercentage,
                backgroundColor: isDark ? AppTheme.darkCard : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  financeProvider.budgetSpentPercentage >= 1.0 ? AppTheme.accentRed : AppTheme.primaryColor,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: ${Formatters.formatCurrency(financeProvider.totalExpense)}',
                  style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                ),
                Text(
                  'Budget: ${Formatters.formatCurrency(financeProvider.totalBudgetLimit)}',
                  style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalPromptCard(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => const JournalEditScreen()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.edit_note_rounded, color: AppTheme.secondaryColor, size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Reflection & Notes',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'What made you feel grateful or accomplished today?',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.secondaryColor),
          ],
        ),
      ),
    );
  }
}
