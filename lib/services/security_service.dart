import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  static const String _pinKey = 'zenith_journal_pin_hash';
  static const String _pinEnabledKey = 'zenith_journal_pin_enabled';

  static String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  static Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pinEnabledKey) ?? false;
  }

  static Future<bool> hasPinSet() async {
    final prefs = await SharedPreferences.getInstance();
    final hash = prefs.getString(_pinKey);
    return hash != null && hash.isNotEmpty;
  }

  static Future<bool> setPin(String newPin) async {
    if (newPin.length < 4) return false;
    final prefs = await SharedPreferences.getInstance();
    final hashed = _hashPin(newPin);
    await prefs.setString(_pinKey, hashed);
    await prefs.setBool(_pinEnabledKey, true);
    return true;
  }

  static Future<bool> verifyPin(String enteredPin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_pinKey);
    if (storedHash == null) return true; // No PIN set
    final inputHash = _hashPin(enteredPin);
    return storedHash == inputHash;
  }

  static Future<void> disablePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
    await prefs.setBool(_pinEnabledKey, false);
  }
}
