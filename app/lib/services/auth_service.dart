import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/constants.dart';
import '../utils/storage_helper.dart';

class AuthService {
  static const String _baseUrl = ApiConstants.baseUrl;

  // Login
  static Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final user = User.fromJson(data['user']);
        final token = data['token'] as String;
        
        // Salvar token no storage
        await StorageHelper.saveToken(token);
        await StorageHelper.saveUser(user);

        return AuthResponse(
          success: true,
          user: user,
          token: token,
          message: data['message'],
        );
      } else {
        return AuthResponse(
          success: false,
          error: data['error'] ?? 'Erro no login',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        error: 'Erro de conexão: $e',
      );
    }
  }

  // Registro
  static Future<AuthResponse> register({
    required String email,
    required String username,
    required String password,
    String? name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'username': username,
          'password': password,
          'name': name,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        final user = User.fromJson(data['user']);
        final token = data['token'] as String;
        
        // Salvar token no storage
        await StorageHelper.saveToken(token);
        await StorageHelper.saveUser(user);

        return AuthResponse(
          success: true,
          user: user,
          token: token,
          message: data['message'],
        );
      } else {
        return AuthResponse(
          success: false,
          error: data['error'] ?? 'Erro no registro',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        error: 'Erro de conexão: $e',
      );
    }
  }

  // Logout
  static Future<void> logout() async {
    await StorageHelper.clearAll();
  }

  // Verificar se está logado
  static Future<bool> isLoggedIn() async {
    final token = await StorageHelper.getToken();
    return token != null && token.isNotEmpty;
  }

  // Obter usuário atual
  static Future<User?> getCurrentUser() async {
    return await StorageHelper.getUser();
  }

  // Obter token atual
  static Future<String?> getCurrentToken() async {
    return await StorageHelper.getToken();
  }

  // Verificar se o token é válido (pode ser expandido)
  static Future<bool> isTokenValid() async {
    final token = await getCurrentToken();
    if (token == null) return false;
    
    // Aqui você pode implementar uma verificação no servidor
    // Por enquanto, apenas verifica se existe
    return token.isNotEmpty;
  }
}

class AuthResponse {
  final bool success;
  final User? user;
  final String? token;
  final String? message;
  final String? error;

  AuthResponse({
    required this.success,
    this.user,
    this.token,
    this.message,
    this.error,
  });
}