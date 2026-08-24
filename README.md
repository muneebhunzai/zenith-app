# Zenith - Offline-First Personal Management Android App

**Zenith** is a standalone, 100% offline-first personal management mobile application built with Flutter & Dart for Android. It stores all data locally in an SQLite database (`sqflite`), requires no external servers or analytics tracking, and works completely without internet access.

---

## 🌟 Core Modules

### 1. Dashboard / Today Overview
- **Visual Overview**: Routine progress percentage, daily prayer status, net financial balance, and daily mood picker.
- **Immediate Checklists**: Tap to mark today's routines and prayers complete directly from the dashboard.
- **Speed Dial FAB**: Quick actions to log an expense, add a task/habit, or write a private note.

### 2. Daily Routine & Schedule Manager
- **Visual Daily Timeline**: Chronological time-blocking view with priority badges (High, Medium, Low).
- **Checklists**: Segmented into Morning, Afternoon, and Evening routine blocks with auto-reset tracking.
- **Habit Tracker**: Habit cards featuring current flame streaks (`🔥 X day streak`) and 7-day completion bubbles.

### 3. Personal Finance & Budget Tracker
- **Income & Expense Tracking**: Categorized transactions with date picker and notes.
- **Category Spending Donut Chart**: Visual distribution powered by `fl_chart`.
- **Monthly Budget Planner**: Spending limits per category with progress bars and over-budget warnings.
- **Local CSV Export**: Export all financial records to a `.csv` file saved to local device storage.

### 4. Prayer & Reflection Reminders
- **Customizable Daily Schedule**: Pre-configured with 5 daily reflections (Fajr, Dhuhr, Asr, Maghrib, Isha) with editable times.
- **Local Offline Alarms**: Scheduled recurring notifications using `flutter_local_notifications` and exact alarms.
- **Completion Checklists**: Daily checkoffs with progress indicator.

### 5. Private Journal & Mood Notes
- **Rich Markdown Editor**: Write thoughts with Markdown syntax and a live rendered preview toggle.
- **Mood Tracking**: Filter notes by mood (Great, Good, Neutral, Low, Stressed).
- **Tagging & Instant Search**: Fast keyword and tag searching.
- **Privacy PIN Lock**: Optional 4-digit PIN gatekeeper with SHA-256 local hashing.

---

## 🏗️ Architecture & Technology Stack

- **Framework**: Flutter 3.x / Dart 3.x
- **Target OS**: Android (API 21+ / Android 5.0 to Android 14+)
- **State Management**: `provider` (`MultiProvider`)
- **Local Database**: SQLite (`sqflite` + `path_provider`)
- **Notifications**: `flutter_local_notifications` + `timezone`
- **Charts**: `fl_chart`
- **Export**: `csv`
- **Security**: Local SHA-256 PIN hashing (`crypto` + `shared_preferences`)

---

## 🗄️ SQLite Database Schema

```sql
-- 1. Routines & Habits
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
);

-- 2. Financial Transactions
CREATE TABLE transactions (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL,
  amount REAL NOT NULL,
  category TEXT NOT NULL,
  date TEXT NOT NULL,
  note TEXT,
  created_at TEXT NOT NULL
);

-- 3. Monthly Budgets
CREATE TABLE budgets (
  category TEXT PRIMARY KEY,
  monthly_limit REAL NOT NULL
);

-- 4. Prayer & Reflection Reminders
CREATE TABLE prayer_reminders (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  scheduled_time TEXT NOT NULL,
  is_enabled INTEGER NOT NULL,
  is_completed_today INTEGER NOT NULL,
  last_completed_date TEXT
);

-- 5. Private Journal Entries
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
);

-- 6. Settings Key-Value Store
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
```

---

## 🚀 How to Compile & Build the Release APK

### Prerequisites
1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.10 or higher).
2. Install [Android Studio](https://developer.android.com/studio) with Android SDK (API 34) and command-line tools.

### Step 1: Open the Project Directory
```bash
cd C:\Users\Muneb\.gemini\antigravity\scratch\zenith_life
```

### Step 2: Fetch Dependencies
```bash
flutter pub get
```

### Step 3: Test on a Connected Device or Emulator
```bash
flutter run
```

### Step 4: Build the Standalone Release APK
Run the following command to generate the optimized release APK:
```bash
flutter build apk --release
```

The compiled release APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 🔒 Offline & Security Verification
- Zenith makes **0 network calls** (no HTTP/REST, no Firebase, no cloud sync).
- All permissions in `AndroidManifest.xml` are strictly for local on-device alarms (`POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`) and local document export.
- Private notes are protected behind a local PIN hash.
