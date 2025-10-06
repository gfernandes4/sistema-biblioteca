/// Constantes gerais da aplicação
class AppConstants {
  // Informações do app
  static const String appName = 'Sistema Biblioteca Digital';
  static const String appVersion = '1.0.0';
  
  // Chaves para SharedPreferences
  static const String tokenKey = 'auth_token';
  static const String userTypeKey = 'user_type';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  
  // Tipos de usuário
  static const String adminType = 'admin';
  static const String schoolType = 'school';
  static const String studentType = 'student';
  
  // Configurações de empréstimo
  static const int maxBooksPerUser = 3;
  static const int loanDurationDays = 14;
  
  // Formatos de arquivo suportados
  static const List<String> supportedBookFormats = [
    'pdf',
    'epub',
  ];
  
  // Tamanhos de arquivo
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  
  // Database
  static const String databaseName = 'biblioteca_local.db';
  static const int databaseVersion = 1;
}
