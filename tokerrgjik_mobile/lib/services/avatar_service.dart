import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Simplified Avatar Service - No cloud upload needed!
/// Avatars are stored locally in the app using SharedPreferences.
/// Perfect for offline-first apps and no need for cloud storage APIs.
class AvatarService {
  static final AvatarService _instance = AvatarService._internal();
  factory AvatarService() => _instance;
  AvatarService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery and save locally
  Future<String?> changeAvatar({
    required String username,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      // Pick image from gallery or camera
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image == null) {
        debugPrint('No image selected');
        return null;
      }
      
      // Read image as bytes
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      // Save to local storage (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_$username', base64Image);
      
      debugPrint('✅ Avatar saved locally for $username');
      return base64Image;
      
    } catch (e) {
      debugPrint('❌ Error picking/saving avatar: $e');
      return null;
    }
  }
  
  /// Get avatar from local storage
  Future<String?> getAvatar(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('avatar_$username');
    } catch (e) {
      debugPrint('Error getting avatar: $e');
      return null;
    }
  }
  
  /// Delete avatar
  Future<bool> deleteAvatar(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove('avatar_$username');
    } catch (e) {
      debugPrint('Error deleting avatar: $e');
      return false;
    }
  }
  
  /// Get default avatar URL (from ui-avatars.com)
  static String getDefaultAvatar(String username) {
    final firstLetter = username.isNotEmpty ? username[0].toUpperCase() : 'A';
    return 'https://ui-avatars.com/api/?name=$firstLetter&background=667eea&color=fff&size=200';
  }
  
  /// Check if user has a custom avatar
  Future<bool> hasCustomAvatar(String username) async {
    final avatar = await getAvatar(username);
    return avatar != null;
  }
}
