import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileProvider extends ChangeNotifier {
  String _name = 'Mayur';
  String? _profilePictureUrl;
  String? _localImagePath;

  String get name => _name;
  String? get profilePictureUrl => _profilePictureUrl;
  String? get localImagePath => _localImagePath;

  static UserProfileProvider? _instance;
  static UserProfileProvider get instance {
    _instance ??= UserProfileProvider();
    return _instance!;
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('user_name') ?? 'Mayur';
    _profilePictureUrl = prefs.getString('user_profile_picture_url');
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    _name = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    notifyListeners();
  }

  Future<void> updateProfilePicture({
    String? localPath,
    String? networkUrl,
  }) async {
    _localImagePath = localPath;
    if (networkUrl != null && networkUrl.isNotEmpty) {
      _profilePictureUrl = networkUrl;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_picture_url', networkUrl);
    }
    notifyListeners();
  }

  void clearLocalImage() {
    _localImagePath = null;
    notifyListeners();
  }
}