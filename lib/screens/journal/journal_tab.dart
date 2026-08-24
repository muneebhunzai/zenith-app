import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/journal_entry.dart';
import '../../providers/journal_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import 'journal_edit_screen.dart';
import 'pin_lock_screen.dart';

class JournalTab extends StatefulWidget {
  const JournalTab({super.key});

  @override
  State<JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends State<JournalTab> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _moodFilters = ['All', 'Great', 'Good', 'Neutral', 'Low', 'Stressed'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // PIN Protection Check
    if (journalProvider.isPinProtected && !journalProvider.isUnlocked) {
      return PinLockScreen(
        onPinEntered: (pin) async {
          final success = await journalProvider.unlockWithPin(pin);
          if (!success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Incorrect PIN. Please try again.'),
                backgroundColor: AppTheme.accentRed,
              ),
            );
          }
        },
      );
    }

    final entries = journalProvider.filteredEntries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal & Reflection'),
        actions: [
          if (journalProvider.isPinProtected)
            IconButton(
              icon: const Icon(Icons.lock_outline_rounded),
              tooltip: 'Lock Journal',
              onPressed: () {
                journalProvider.lock();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => journalProvider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search notes, tags, thoughts...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          journalProvider.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppTheme.darkCard : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),

          // Mood Filter Chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _moodFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final mood = _moodFilters[index];
                final isSelected = journalProvider.selectedMoodFilter == mood;

                return ChoiceChip(
                  label: Text(mood),
                  selected: isSelected,
                  onSelected: (_) => journalProvider.setMoodFilter(mood),
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  avatar: mood != 'All'
                      ? Icon(
                          Formatters.getMoodIcon(mood),
                          size: 16,
                          color: Formatters.getMoodColor(mood),
                        )
                      : null,
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Entry List
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_stories_outlined,
                          size: 64,
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No journal entries found',
                          style: TextStyle(
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap + to write down your thoughts',
                          style: TextStyle(
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _buildJournalCard(context, entry, journalProvider, isDark);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_journal_tab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const JournalEditScreen(),
            ),
          );
        },
        child: const Icon(Icons.edit_rounded),
      ),
    );
  }

  Widget _buildJournalCard(
    BuildContext context,
    JournalEntry entry,
    JournalProvider provider,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JournalEditScreen(entry: entry),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: entry.isPinned
                ? AppTheme.primaryColor.withOpacity(0.6)
                : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            width: entry.isPinned ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header: Mood Badge & Date & Pin Action
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Formatters.getMoodColor(entry.mood).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Formatters.getMoodIcon(entry.mood),
                        color: Formatters.getMoodColor(entry.mood),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.mood,
                        style: TextStyle(
                          color: Formatters.getMoodColor(entry.mood),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  Formatters.formatDate(entry.date),
                  style: TextStyle(
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    entry.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 18,
                    color: entry.isPinned ? AppTheme.primaryColor : Colors.grey,
                  ),
                  tooltip: entry.isPinned ? 'Unpin' : 'Pin to top',
                  onPressed: () => provider.togglePin(entry.id),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
                  tooltip: 'Delete',
                  onPressed: () => _confirmDelete(context, entry, provider),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              entry.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Snippet Preview
            Text(
              entry.content.replaceAll('#', '').replaceAll('*', '').trim(),
              style: TextStyle(
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Tags
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: entry.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, JournalEntry entry, JournalProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Journal Entry?'),
        content: Text('Are you sure you want to delete "${entry.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteEntry(entry.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }
}
