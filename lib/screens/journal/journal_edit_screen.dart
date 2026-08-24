import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../models/journal_entry.dart';
import '../../providers/journal_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

class JournalEditScreen extends StatefulWidget {
  final JournalEntry? entry;

  const JournalEditScreen({super.key, this.entry});

  @override
  State<JournalEditScreen> createState() => _JournalEditScreenState();
}

class _JournalEditScreenState extends State<JournalEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late String _selectedMood;
  late String _date;
  bool _isPreviewMode = false;
  final List<String> _moods = ['Great', 'Good', 'Neutral', 'Low', 'Stressed'];

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _titleController = TextEditingController(text: entry?.title ?? '');
    _contentController = TextEditingController(text: entry?.content ?? '');
    _tagsController = TextEditingController(text: entry?.tags.join(', ') ?? '');
    _selectedMood = entry?.mood ?? 'Good';
    _date = entry?.date ?? Formatters.todayString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime initial = DateTime.tryParse(_date) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _date = picked.toIso8601String().substring(0, 10);
      });
    }
  }

  Future<void> _saveEntry() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title or some thoughts.')),
      );
      return;
    }

    final rawTags = _tagsController.text.split(',');
    final tags = rawTags
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final nowStr = DateTime.now().toIso8601String();
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);

    if (widget.entry == null) {
      final newEntry = JournalEntry(
        id: 'journal_${DateTime.now().millisecondsSinceEpoch}',
        title: title.isEmpty ? 'Untitled Entry' : title,
        content: content,
        mood: _selectedMood,
        tags: tags,
        date: _date,
        isPinned: false,
        createdAt: nowStr,
        updatedAt: nowStr,
      );
      await journalProvider.addEntry(newEntry);
    } else {
      final updatedEntry = widget.entry!.copyWith(
        title: title.isEmpty ? 'Untitled Entry' : title,
        content: content,
        mood: _selectedMood,
        tags: tags,
        date: _date,
        updatedAt: nowStr,
      );
      await journalProvider.updateEntry(updatedEntry);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'New Entry' : 'Edit Entry'),
        actions: [
          IconButton(
            icon: Icon(_isPreviewMode ? Icons.edit_note_rounded : Icons.visibility_rounded),
            tooltip: _isPreviewMode ? 'Switch to Edit' : 'Preview Markdown',
            onPressed: () {
              setState(() {
                _isPreviewMode = !_isPreviewMode;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.check_rounded, color: AppTheme.primaryColor),
            tooltip: 'Save Entry',
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & Mood Row
            Row(
              children: [
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          Formatters.formatDate(_date),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Mood: ',
                  style: TextStyle(
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    fontSize: 13,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedMood,
                  underline: const SizedBox(),
                  items: _moods.map((mood) {
                    return DropdownMenuItem(
                      value: mood,
                      child: Row(
                        children: [
                          Icon(
                            Formatters.getMoodIcon(mood),
                            color: Formatters.getMoodColor(mood),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(mood),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMood = val;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title TextField
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Entry Title...',
                border: InputBorder.none,
              ),
            ),
            const Divider(),

            // Tags TextField
            TextField(
              controller: _tagsController,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Tags (e.g. Work, Ideas, Reflection - comma separated)',
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.tag_rounded, size: 18),
                hintStyle: TextStyle(
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Content or Markdown Preview
            if (_isPreviewMode) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
                child: MarkdownBody(
                  data: _contentController.text.isEmpty
                      ? '*Nothing written yet.*'
                      : _contentController.text,
                  selectable: true,
                ),
              ),
            ] else ...[
              TextField(
                controller: _contentController,
                maxLines: null,
                minLines: 12,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontSize: 15, height: 1.5),
                decoration: InputDecoration(
                  hintText: 'Write in Markdown...\n\n# Heading\n- Bullet points\n**Bold text**',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
