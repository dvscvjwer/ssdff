import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileManager extends ChangeNotifier {
  String? _imagePath;
  String? _imageBase64;
  String? _userName;
  
  String? get imagePath => _imagePath;
  String? get imageBase64 => _imageBase64;
  String? get userName => _userName;

  ProfileManager() {
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    
    _userName = prefs.getString('profile_user_name');

    if (kIsWeb) {
      _imageBase64 = prefs.getString('profile_image_b64');
    } else {
      _imagePath = prefs.getString('profile_image_path');
      if (_imagePath != null) {
        final file = File(_imagePath!);
        if (!await file.exists()) {
          _imagePath = null;
        }
      }
    }
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_user_name', name);
    notifyListeners();
  }

  Future<void> pickAndSaveImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (pickedFile == null) return;

    final prefs = await SharedPreferences.getInstance();

    if (kIsWeb) {
      final bytes = await pickedFile.readAsBytes();
      _imageBase64 = base64Encode(bytes);
      await prefs.setString('profile_image_b64', _imageBase64!);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final extension = pickedFile.name.split('.').last;
      final newPath = '${directory.path}/profile_avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';
      
      final savedFile = await File(pickedFile.path).copy(newPath);
      _imagePath = savedFile.path;
      await prefs.setString('profile_image_path', _imagePath!);
    }
    
    notifyListeners();
  }
}

final profileManager = ProfileManager();
