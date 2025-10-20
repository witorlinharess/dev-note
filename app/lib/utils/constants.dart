class ApiConstants {
  static const String baseUrl = 'http://localhost:3000/api';
  
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