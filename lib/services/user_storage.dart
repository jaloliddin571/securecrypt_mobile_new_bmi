import 'package:shared_preferences/shared_preferences.dart';
import 'user_profile.dart';

class UserStorage {
  static const String _key = 'user_profile';

  static Future<void> saveUser(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, user.toJson());
  }

  static Future<UserProfile?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;
    return UserProfile.fromJson(jsonString);
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
