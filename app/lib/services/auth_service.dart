import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import '../utils/storage_helper.dart';

class AuthService {
  static final String _baseUrl = ApiConstants.baseUrl;

  // Login
  static Future<AuthResponse> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'identifier': identifier,
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

  // Update profile name
  static Future<AuthResponse> updateProfileName(String name) async {
    try {
      final token = await getCurrentToken();
      if (token == null) return AuthResponse(success: false, error: 'Usuário não autenticado');

      final response = await http.put(
        Uri.parse('$_baseUrl/auth/profile/name'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode({'name': name}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data['user'] != null) {
          final updatedUser = User.fromJson(data['user']);
          await StorageHelper.saveUser(updatedUser);
        }
        return AuthResponse(success: true, message: data['message']);
      } else {
        return AuthResponse(success: false, error: data['error'] ?? 'Erro ao atualizar nome');
      }
    } catch (e) {
      return AuthResponse(success: false, error: 'Erro de conexão: $e');
    }
  }

  // Delete profile photo
  static Future<AuthResponse> deleteProfilePhoto() async {
    try {
      final token = await getCurrentToken();
      if (token == null) return AuthResponse(success: false, error: 'Usuário não autenticado');

      final response = await http.delete(
        Uri.parse('$_baseUrl/auth/profile/photo'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data['user'] != null) {
          final updatedUser = User.fromJson(data['user']);
          await StorageHelper.saveUser(updatedUser);
        }
        return AuthResponse(success: true, message: data['message']);
      } else {
        return AuthResponse(success: false, error: data['error'] ?? 'Erro ao excluir foto');
      }
    } catch (e) {
      return AuthResponse(success: false, error: 'Erro de conexão: $e');
    }
  }

  // Atualizar foto de perfil
  static Future<AuthResponse> updateProfilePhoto(String imagePath) async {
    try {
      final token = await getCurrentToken();
      if (token == null) {
        return AuthResponse(success: false, error: 'Token não encontrado');
      }

      // Verificar se o arquivo existe
      final file = File(imagePath);
      if (!await file.exists()) {
        return AuthResponse(success: false, error: 'Arquivo de imagem não encontrado');
      }

      print('📷 Fazendo upload da foto de perfil...');
      print('📁 Arquivo: $imagePath');

      var request = http.MultipartRequest('PUT', Uri.parse('$_baseUrl/auth/profile/photo'));
      request.headers['Authorization'] = 'Bearer $token';
      
      // Detectar tipo MIME baseado na extensão
      String contentType = 'image/jpeg'; // padrão
      final extension = imagePath.toLowerCase();
      if (extension.contains('.png')) {
        contentType = 'image/png';
      } else if (extension.contains('.webp')) {
        contentType = 'image/webp';
      } else if (extension.contains('.gif')) {
        contentType = 'image/gif';
      }
      
      print('🏷️ Content-Type detectado: $contentType');
      
      request.files.add(await http.MultipartFile.fromPath(
        'photo', 
        imagePath,
        filename: 'profile.jpg',
        contentType: MediaType.parse(contentType),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('✅ Status: ${response.statusCode}');
      print('📋 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['user'] != null) {
          final updatedUser = User.fromJson(data['user']);
          await StorageHelper.saveUser(updatedUser);
        }

        return AuthResponse(
          success: true,
          message: data['message'] ?? 'Foto de perfil atualizada com sucesso',
        );
      } else {
        try {
          final data = json.decode(response.body);
          return AuthResponse(
            success: false,
            error: data['error'] ?? data['message'] ?? 'Erro ao atualizar foto de perfil',
          );
        } catch (e) {
          return AuthResponse(
            success: false,
            error: 'Erro do servidor (Status: ${response.statusCode})',
          );
        }
      }

    } catch (e) {
      print('❌ Erro no upload da foto: $e');
      return AuthResponse(success: false, error: 'Erro de conexão: $e');
    }
  }

  // Delete account
  static Future<AuthResponse> deleteAccount() async {
    try {
      final token = await getCurrentToken();
      if (token == null) return AuthResponse(success: false, error: 'Usuário não autenticado');

      final response = await http.delete(
        Uri.parse('$_baseUrl/auth/account'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Limpar dados locais após deletar a conta
        await logout();
        return AuthResponse(success: true, message: data['message'] ?? 'Conta excluída com sucesso');
      } else {
        return AuthResponse(success: false, error: data['error'] ?? 'Erro ao excluir conta');
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