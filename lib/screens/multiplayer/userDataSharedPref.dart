import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static void saveData(String name) async {
    final localData = await SharedPreferences.getInstance();
    localData.setString('name', name);
  }

  static Future<String> getData() async {
    final localData = await SharedPreferences.getInstance();
    return localData.getString('name') ?? '';
  }
}
