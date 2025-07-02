// auth_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'token');
  }
}
