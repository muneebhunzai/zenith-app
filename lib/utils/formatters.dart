import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final NumberFormat _compactCurrency = NumberFormat.compactCurrency(symbol: '\$');

  static String formatCurrency(double amount) {
    return _currency.format(amount);
  }

  static String formatCompactCurrency(double amount) {
    return _compactCurrency.format(amount);
  }

  static String formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('MMM dd, yyyy').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  static String formatShortDate(DateTime dt) {
    return DateFormat('EEE, MMM d').format(dt);
  }

  static String formatTime24to12(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2026, 1, 1, hour, minute);
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return time24;
    }
  }

  static String todayString() {
    return DateTime.now().toIso8601String().substring(0, 10);
  }

  static Color getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'great':
        return const Color(0xFF10B981);
      case 'good':
        return const Color(0xFF3B82F6);
      case 'neutral':
        return const Color(0xFF8B5CF6);
      case 'low':
        return const Color(0xFFF59E0B);
      case 'stressed':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  static IconData getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'great':
        return Icons.sentiment_very_satisfied_rounded;
      case 'good':
        return Icons.sentiment_satisfied_alt_rounded;
      case 'neutral':
        return Icons.sentiment_neutral_rounded;
      case 'low':
        return Icons.sentiment_dissatisfied_rounded;
      case 'stressed':
        return Icons.sentiment_very_dissatisfied_rounded;
      default:
        return Icons.sentiment_satisfied_rounded;
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'salary':
        return Icons.account_balance_wallet_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      case 'health':
        return Icons.favorite_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
