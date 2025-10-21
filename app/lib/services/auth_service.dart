import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/constants.dart';
import '../utils/storage_helper.dart';

class AuthService {
  static final String _baseUrl = ApiConstants.baseUrl;

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
        if (data == null || data['user'] == null) {
          return AuthResponse(success: false, error: 'Resposta inválida do servidor');
        }

        final userMap = data['user'];
        try {
          final user = User.fromJson(userMap);
          final token = data['token']?.toString();

          if (token == null || token.isEmpty) {
            return AuthResponse(success: false, error: 'Token ausente do servidor');
          }

          // Salvar token no storage
          await StorageHelper.saveToken(token);
          await StorageHelper.saveUser(user);

          return AuthResponse(
            success: true,
            user: user,
            token: token,
            message: data['message'],
          );
        } catch (e) {
          return AuthResponse(success: false, error: 'Erro ao processar usuário: $e');
        }
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
    String? username,
    required String password,
    String? name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          if (username != null) 'username': username,
          'password': password,
          'name': name,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        if (data == null || data['user'] == null) {
          return AuthResponse(success: false, error: 'Resposta inválida do servidor');
        }

        final userMap = data['user'];
        try {
          final user = User.fromJson(userMap);
          final token = data['token']?.toString();

          if (token == null || token.isEmpty) {
            return AuthResponse(success: false, error: 'Token ausente do servidor');
          }

          // Salvar token no storage
          await StorageHelper.saveToken(token);
          await StorageHelper.saveUser(user);

          return AuthResponse(
            success: true,
            user: user,
            token: token,
            message: data['message'],
          );
        } catch (e) {
          return AuthResponse(success: false, error: 'Erro ao processar usuário: $e');
        }
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

  // Change password (requires authenticated user)
  static Future<AuthResponse> changePassword(String currentPassword, String newPassword) async {
    try {
      final token = await getCurrentToken();
      if (token == null) return AuthResponse(success: false, error: 'Usuário não autenticado');

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/change-password'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode({'currentPassword': currentPassword, 'newPassword': newPassword}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse(success: true, message: data['message']);
      } else {
        return AuthResponse(success: false, error: data['error'] ?? 'Erro ao alterar senha');
      }
    } catch (e) {
      return AuthResponse(success: false, error: 'Erro de conexão: $e');
    }
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