import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/routine.dart';
import '../models/transaction_item.dart';
import '../models/budget.dart';
import '../models/prayer_reminder.dart';
import '../models/journal_entry.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('zenith_life.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Routines Table
    await db.execute('''
      CREATE TABLE routines (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        time TEXT NOT NULL,
        is_recurring INTEGER NOT NULL,
        days_of_week TEXT NOT NULL,
        routine_type TEXT NOT NULL,
        priority TEXT NOT NULL,
        is_completed INTEGER NOT NULL,
        streak INTEGER NOT NULL,
        last_completed_date TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 2. Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 3. Budgets Table
    await db.execute('''
      CREATE TABLE budgets (
        category TEXT PRIMARY KEY,
        monthly_limit REAL NOT NULL
      )
    ''');

    // 4. Prayer & Reflection Reminders Table
    await db.execute('''
      CREATE TABLE prayer_reminders (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        scheduled_time TEXT NOT NULL,
        is_enabled INTEGER NOT NULL,
        is_completed_today INTEGER NOT NULL,
        last_completed_date TEXT
      )
    ''');

    // 5. Journal Entries Table
    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        mood TEXT NOT NULL,
        tags TEXT NOT NULL,
        date TEXT NOT NULL,
        is_pinned INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 6. Settings Key-Value Table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Pre-populate with essential defaults
    await _seedDefaults(db);
  }

  Future<void> _seedDefaults(Database db) async {
    final now = DateTime.now();
    final todayStr = now.toIso8601String().substring(0, 10);
    final nowStr = now.toIso8601String();

    // Default Prayer Reminders
    final defaultPrayers = [
      PrayerReminder(id: 'prayer_1', name: 'Fajr / Dawn Reflection', scheduledTime: '05:30', isEnabled: true),
      PrayerReminder(id: 'prayer_2', name: 'Dhuhr / Midday Pause', scheduledTime: '13:00', isEnabled: true),
      PrayerReminder(id: 'prayer_3', name: 'Asr / Afternoon Mindfulness', scheduledTime: '16:45', isEnabled: true),
      PrayerReminder(id: 'prayer_4', name: 'Maghrib / Sunset Gratitude', scheduledTime: '19:15', isEnabled: true),
      PrayerReminder(id: 'prayer_5', name: 'Isha / Night Reflection', scheduledTime: '20:45', isEnabled: true),
    ];
    for (var prayer in defaultPrayers) {
      await db.insert('prayer_reminders', prayer.toMap());
    }

    // Default Routines
    final defaultRoutines = [
      Routine(
        id: 'routine_1',
        title: 'Hydrate & Morning Stretch',
        time: '07:00',
        routineType: 'morning',
        priority: 'high',
        streak: 3,
        lastCompletedDate: now.subtract(const Duration(days: 1)).toIso8601String().substring(0, 10),
        createdAt: nowStr,
      ),
      Routine(
        id: 'routine_2',
        title: '90-min Deep Focus Work Block',
        time: '09:30',
        routineType: 'morning',
        priority: 'high',
        streak: 5,
        lastCompletedDate: now.subtract(const Duration(days: 1)).toIso8601String().substring(0, 10),
        createdAt: nowStr,
      ),
      Routine(
        id: 'routine_3',
        title: 'Afternoon Walk & Screen Break',
        time: '15:00',
        routineType: 'afternoon',
        priority: 'medium',
        streak: 2,
        lastCompletedDate: now.subtract(const Duration(days: 1)).toIso8601String().substring(0, 10),
        createdAt: nowStr,
      ),
      Routine(
        id: 'routine_4',
        title: '30-min Reading & Night Journaling',
        time: '21:30',
        routineType: 'evening',
        priority: 'medium',
        streak: 4,
        lastCompletedDate: now.subtract(const Duration(days: 1)).toIso8601String().substring(0, 10),
        createdAt: nowStr,
      ),
    ];
    for (var routine in defaultRoutines) {
      await db.insert('routines', routine.toMap());
    }

    // Default Budgets
    final defaultBudgets = [
      Budget(category: 'Food', monthlyLimit: 450.0),
      Budget(category: 'Transport', monthlyLimit: 120.0),
      Budget(category: 'Bills', monthlyLimit: 300.0),
      Budget(category: 'Shopping', monthlyLimit: 150.0),
      Budget(category: 'Health', monthlyLimit: 100.0),
      Budget(category: 'Entertainment', monthlyLimit: 80.0),
    ];
    for (var budget in defaultBudgets) {
      await db.insert('budgets', budget.toMap());
    }

    // Default Welcome Journal Entry
    final welcomeEntry = JournalEntry(
      id: 'journal_welcome',
      title: 'Welcome to Zenith',
      content: '''### Welcome to Your Private Offline Space

Zenith keeps **100% of your life data offline** on your device:
- **Daily Schedule & Routines**: Build solid habits, track daily streaks, and organize routines.
- **Personal Finances**: Log expenses and income, view breakdowns, and set monthly category budgets.
- **Prayer & Reflection**: Stay aligned with customizable daily reminders.
- **Private Journal**: Write Markdown thoughts with mood tracking and PIN protection.

*Your data never leaves this phone.*''',
      mood: 'Great',
      tags: ['Personal', 'Mindfulness'],
      date: todayStr,
      isPinned: true,
      createdAt: nowStr,
      updatedAt: nowStr,
    );
    await db.insert('journal_entries', welcomeEntry.toMap());

    // Sample Transaction
    final sampleTx = TransactionItem(
      id: 'tx_sample_1',
      type: 'expense',
      amount: 14.50,
      category: 'Food',
      date: todayStr,
      note: 'Morning coffee and healthy breakfast',
      createdAt: nowStr,
    );
    await db.insert('transactions', sampleTx.toMap());
  }

  // ================= ROUTINES CRUD =================
  Future<List<Routine>> getRoutines() async {
    final db = await database;
    final maps = await db.query('routines', orderBy: 'time ASC');
    return maps.map((m) => Routine.fromMap(m)).toList();
  }

  Future<int> insertRoutine(Routine routine) async {
    final db = await database;
    return await db.insert('routines', routine.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateRoutine(Routine routine) async {
    final db = await database;
    return await db.update('routines', routine.toMap(), where: 'id = ?', whereArgs: [routine.id]);
  }

  Future<int> deleteRoutine(String id) async {
    final db = await database;
    return await db.delete('routines', where: 'id = ?', whereArgs: [id]);
  }

  // ================= TRANSACTIONS CRUD =================
  Future<List<TransactionItem>> getTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC, created_at DESC');
    return maps.map((m) => TransactionItem.fromMap(m)).toList();
  }

  Future<int> insertTransaction(TransactionItem item) async {
    final db = await database;
    return await db.insert('transactions', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateTransaction(TransactionItem item) async {
    final db = await database;
    return await db.update('transactions', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ================= BUDGETS CRUD =================
  Future<List<Budget>> getBudgets() async {
    final db = await database;
    final maps = await db.query('budgets');
    return maps.map((m) => Budget.fromMap(m)).toList();
  }

  Future<int> setBudget(Budget budget) async {
    final db = await database;
    return await db.insert('budgets', budget.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ================= PRAYER REMINDERS CRUD =================
  Future<List<PrayerReminder>> getPrayers() async {
    final db = await database;
    final maps = await db.query('prayer_reminders', orderBy: 'scheduled_time ASC');
    return maps.map((m) => PrayerReminder.fromMap(m)).toList();
  }

  Future<int> insertPrayer(PrayerReminder prayer) async {
    final db = await database;
    return await db.insert('prayer_reminders', prayer.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updatePrayer(PrayerReminder prayer) async {
    final db = await database;
    return await db.update('prayer_reminders', prayer.toMap(), where: 'id = ?', whereArgs: [prayer.id]);
  }

  Future<int> deletePrayer(String id) async {
    final db = await database;
    return await db.delete('prayer_reminders', where: 'id = ?', whereArgs: [id]);
  }

  // ================= JOURNAL ENTRIES CRUD =================
  Future<List<JournalEntry>> getJournalEntries() async {
    final db = await database;
    final maps = await db.query('journal_entries', orderBy: 'is_pinned DESC, date DESC, updated_at DESC');
    return maps.map((m) => JournalEntry.fromMap(m)).toList();
  }

  Future<int> insertJournalEntry(JournalEntry entry) async {
    final db = await database;
    return await db.insert('journal_entries', entry.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateJournalEntry(JournalEntry entry) async {
    final db = await database;
    return await db.update('journal_entries', entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<int> deleteJournalEntry(String id) async {
    final db = await database;
    return await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }

  // ================= SETTINGS CRUD =================
  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return null;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
