// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  static void saveData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is int) {
      prefs.setInt(key, value);
    } else if (value is String) {
      prefs.setString(key, value);
    } else if (value is bool) {
      prefs.setBool(key, value);
    } else {
      debugPrint("Invalid Type");
    }
  }
  static Future<int> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    int i = prefs.getInt(key) ?? 0;
    return i;
  }
  static Future<String> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String str = prefs.getString(key) ?? "";
    return str;
  }
  static Future<dynamic> readData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    dynamic obj = prefs.get(key);
    return obj;
  }

  static Future<bool> deleteData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}