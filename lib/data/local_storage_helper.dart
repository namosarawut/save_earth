import 'dart:convert';
import 'package:save_earth/data/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LocalStorageHelper {
  static const String _tokenKey = "auth_token";
  static const String _userKey = "auth_user";

  /// บันทึก Token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// ดึง Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// ลบ Token (ใช้เมื่อล็อกเอาต์)
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// บันทึกข้อมูล User
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  /// ดึงข้อมูล User
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson));
  }

  /// ลบข้อมูล User (ใช้เมื่อล็อกเอาต์)
  static Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  /// ลบข้อมูลทั้งหมด (Token + User) -> ใช้เมื่อล็อกเอาต์
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
