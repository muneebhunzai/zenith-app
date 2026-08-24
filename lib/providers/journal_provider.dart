import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/journal_entry.dart';
import '../services/security_service.dart';
import '../utils/formatters.dart';

class JournalProvider extends ChangeNotifier {
  List<JournalEntry> _entries = [];
  bool _isLoading = true;
  String _selectedMoodFilter = 'All';
  String _searchQuery = '';
  
  bool _isPinProtected = false;
  bool _isUnlocked = false;

  List<JournalEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String get selectedMoodFilter => _selectedMoodFilter;
  String get searchQuery => _searchQuery;
  bool get isPinProtected => _isPinProtected;
  bool get isUnlocked => _isUnlocked;

  JournalProvider() {
    loadData();
    checkSecurity();
  }

  Future<void> checkSecurity() async {
    _isPinProtected = await SecurityService.isPinEnabled();
    // If no PIN is set, unlocked is true by default
    if (!_isPinProtected) {
      _isUnlocked = true;
    }
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _entries = await DBHelper.instance.getJournalEntries();

    _isLoading = false;
    notifyListeners();
  }

  void setMoodFilter(String mood) {
    _selectedMoodFilter = mood;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase().trim();
    notifyListeners();
  }

  List<JournalEntry> get filteredEntries {
    return _entries.where((entry) {
      final matchesMood = _selectedMoodFilter == 'All' ||
          entry.mood.toLowerCase() == _selectedMoodFilter.toLowerCase();

      final matchesQuery = _searchQuery.isEmpty ||
          entry.title.toLowerCase().contains(_searchQuery) ||
          entry.content.toLowerCase().contains(_searchQuery) ||
          entry.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));

      return matchesMood && matchesQuery;
    }).toList();
  }

  String get todayMood {
    final today = Formatters.todayString();
    final todayEntry = _entries.firstWhere(
      (e) => e.date == today,
      orElse: () => JournalEntry(id: '', title: '', content: '', mood: 'Good', date: today, createdAt: '', updatedAt: ''),
    );
    return todayEntry.id.isNotEmpty ? todayEntry.mood : 'Good';
  }

  Future<bool> unlockWithPin(String pin) async {
    final isValid = await SecurityService.verifyPin(pin);
    if (isValid) {
      _isUnlocked = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void lock() {
    if (_isPinProtected) {
      _isUnlocked = false;
      notifyListeners();
    }
  }

  Future<bool> enablePin(String pin) async {
    final success = await SecurityService.setPin(pin);
    if (success) {
      _isPinProtected = true;
      _isUnlocked = true;
      notifyListeners();
    }
    return success;
  }

  Future<void> disablePin() async {
    await SecurityService.disablePin();
    _isPinProtected = false;
    _isUnlocked = true;
    notifyListeners();
  }

  Future<void> addEntry(JournalEntry entry) async {
    _entries.insert(0, entry);
    notifyListeners();
    await DBHelper.instance.insertJournalEntry(entry);
  }

  Future<void> updateEntry(JournalEntry entry) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
      notifyListeners();
      await DBHelper.instance.updateJournalEntry(entry);
    }
  }

  Future<void> togglePin(String id) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      final entry = _entries[index];
      final updated = entry.copyWith(isPinned: !entry.isPinned);
      _entries[index] = updated;
      _entries.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.date.compareTo(a.date);
      });
      notifyListeners();
      await DBHelper.instance.updateJournalEntry(updated);
    }
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
    await DBHelper.instance.deleteJournalEntry(id);
  }
}
