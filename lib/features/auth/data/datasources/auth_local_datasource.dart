import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

abstract class AuthLocalDatasource {
  Future<UserModel?> getCachedUser(String id);
  Future<void> cacheUser(UserModel user);
  Future<void> clearUser(String id);
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  const AuthLocalDatasourceImpl();

  static const _cachedUserKey = 'auth_cached_user';

  @override
  Future<UserModel?> getCachedUser(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cachedUserKey);
    if (jsonString == null) return null;

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    final user = UserModel.fromJson(jsonMap);
    return user.id == id ? user : null;
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedUserKey, jsonEncode(user.toJson()));
  }

  @override
  Future<void> clearUser(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cachedUserKey);
    if (jsonString == null) return;

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    if ((jsonMap['id'] as String?) == id) {
      await prefs.remove(_cachedUserKey);
    }
  }
}