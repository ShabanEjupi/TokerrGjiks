import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AvatarService {
  static final AvatarService _instance = AvatarService._internal();
  factory AvatarService() => _instance;
  AvatarService._internal();

  static const String cloudinaryUploadUrl = 'https://api.cloudinary.com/v1_1/YOUR_CLOUD_NAME/image/upload';
  static const String cloudinaryUploadPreset = 'YOUR_UPLOAD_PRESET';
  static const String baseApiUrl = 'https://tokerrgjik.netlify.app/.netlify/functions';

  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery or camera
  Future<XFile?> pickImage({required ImageSource source}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Upload avatar to Cloudinary (or your storage service)
  Future<String?> uploadAvatar(XFile imageFile) async {
    try {
      // For demo purposes, we'll use a simple base64 upload
      // In production, use Cloudinary, AWS S3, or Firebase Storage
      
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Upload to backend (which can then forward to cloud storage)
      final response = await http.post(
        Uri.parse('$baseApiUrl/avatars'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'upload',
          'image': base64Image,
          'filename': imageFile.name,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['url']; // Return the uploaded image URL
      } else {
        debugPrint('Upload failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      return null;
    }
  }

  // Update user's avatar URL in database
  Future<bool> updateUserAvatar(String username, String avatarUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$baseApiUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'update_avatar',
          'username': username,
          'avatar_url': avatarUrl,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating avatar: $e');
      return false;
    }
  }

  // Complete flow: Pick, upload, and update
  Future<String?> changeAvatar({
    required String username,
    required ImageSource source,
  }) async {
    try {
      // Step 1: Pick image
      final imageFile = await pickImage(source: source);
      if (imageFile == null) {
        debugPrint('No image selected');
        return null;
      }

      // Step 2: Upload image
      final avatarUrl = await uploadAvatar(imageFile);
      if (avatarUrl == null) {
        debugPrint('Failed to upload image');
        return null;
      }

      // Step 3: Update user profile
      final success = await updateUserAvatar(username, avatarUrl);
      if (!success) {
        debugPrint('Failed to update user avatar');
        return null;
      }

      return avatarUrl;
    } catch (e) {
      debugPrint('Error changing avatar: $e');
      return null;
    }
  }

  // Get default avatar based on username
  static String getDefaultAvatar(String username) {
    final firstLetter = username.isNotEmpty ? username[0].toUpperCase() : 'A';
    return 'https://ui-avatars.com/api/?name=$firstLetter&background=667eea&color=fff&size=200';
  }
}
