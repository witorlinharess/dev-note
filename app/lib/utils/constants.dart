import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Escolhe a base URL apropriada dependendo da plataforma.
  // - Android emulator (AVD) deve usar 10.0.2.2 para acessar o host local
  // - iOS simulator e web podem usar localhost
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
      // Para iOS simulator e outras plataformas, localhost funciona
      return 'http://localhost:3000/api';
    } catch (_) {
      // Em plataformas onde Platform não está disponível, fallback
      return 'http://localhost:3000/api';
    }
  }

  // Endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String todos = '/todos';
  static const String notifications = '/notifications';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };

  static Map<String, String> authHeaders(String token) {
    return {
      ...defaultHeaders,
      'Authorization': 'Bearer $token',
    };
  }
}

class AppConstants {
  // Prioridades
  static const List<String> priorities = ['LOW', 'MEDIUM', 'HIGH', 'URGENT'];
  
  static const Map<String, String> priorityLabels = {
    'LOW': 'Baixa',
    'MEDIUM': 'Média',
    'HIGH': 'Alta',
    'URGENT': 'Urgente',
  };
  
  // Tipos de notificação
  static const List<String> notificationTypes = [
    'REMINDER',
    'DEADLINE',
    'COMPLETED',
    'ASSIGNED'
  ];
  
  static const Map<String, String> notificationTypeLabels = {
    'REMINDER': 'Lembrete',
    'DEADLINE': 'Prazo',
    'COMPLETED': 'Completa',
    'ASSIGNED': 'Atribuída',
  };
  
  // Configurações de paginação
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;
  
  // Configurações de cache
  static const int cacheExpirationMinutes = 30;
}