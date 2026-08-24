import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/routine_provider.dart';
import '../../theme/app_theme.dart';
import '../journal/pin_lock_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _setupPinModal(BuildContext context, JournalProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SizedBox(
          height: 480,
          child: PinLockScreen(
            title: 'Set 4-Digit Journal PIN',
            subtitle: 'Choose a memorable 4-digit code to lock your journal',
            onPinEntered: (pin) async {
              await provider.enablePin(pin);
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN successfully activated!')),
                );
              }
            },
            onCancel: () => Navigator.pop(ctx),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final journalProvider = Provider.of<JournalProvider>(context);
    final financeProvider = Provider.of<FinanceProvider>(context);
    final routineProvider = Provider.of<RoutineProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Privacy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Offline & Privacy Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_rounded, color: AppTheme.primaryColor, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '100% Offline & Private',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryColor),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'All data is encrypted in local SQLite on your device. Zero cloud trackers.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Appearance Section
          _buildSectionHeader('Appearance', isDark),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6_rounded),
                  title: const Text('Theme Mode'),
                  subtitle: Text(
                    themeProvider.themeMode == ThemeMode.system
                        ? 'Follow System'
                        : (themeProvider.themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode'),
                  ),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeProvider.themeMode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                    ],
                    onChanged: (mode) {
                      if (mode != null) {
                        themeProvider.setThemeMode(mode);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Security & Journal Protection
          _buildSectionHeader('Security & Privacy', isDark),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.lock_outline_rounded),
                  title: const Text('Journal PIN Protection'),
                  subtitle: Text(
                    journalProvider.isPinProtected
                        ? 'PIN is active. Journal requires code.'
                        : 'PIN is disabled. Journal is open.',
                  ),
                  value: journalProvider.isPinProtected,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (enabled) {
                    if (enabled) {
                      _setupPinModal(context, journalProvider);
                    } else {
                      journalProvider.disablePin();
                    }
                  },
                ),
                if (journalProvider.isPinProtected) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.password_rounded),
                    title: const Text('Change PIN'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _setupPinModal(context, journalProvider),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Storage Statistics
          _buildSectionHeader('Device Storage Summary', isDark),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatRow('Daily Routines / Habits', '${routineProvider.totalCount} active items', isDark),
                  const Divider(),
                  _buildStatRow('Financial Transactions', '${financeProvider.transactions.length} records', isDark),
                  const Divider(),
                  _buildStatRow('Private Journal Entries', '${journalProvider.entries.length} notes', isDark),
                  const Divider(),
                  _buildStatRow('Local Database Engine', 'SQLite (sqflite)', isDark),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // App Info
          Center(
            child: Column(
              children: [
                Text(
                  'Zenith Personal Manager v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Built with Flutter & SQLite',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
