import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'src/core/services/service_locator.dart';
import 'src/core/utils/app_themes.dart';
import 'src/core/constants/app_constants.dart';
import 'src/presentation/providers/auth_provider.dart';
import 'src/presentation/providers/books_provider.dart';
import 'src/presentation/providers/theme_provider.dart';
import 'src/presentation/screens/login_screen.dart';
import 'src/presentation/screens/home_screen.dart';
import 'src/presentation/screens/upload_book_screen.dart';
import 'src/presentation/screens/book_reader_screen.dart';

/// Ponto de entrada da aplicação
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o FFI para desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // Inicializar service locator (injeção de dependências)
  await ServiceLocator.instance.init();
  
  runApp(const BibliotecaDigitalApp());
}

/// Widget principal da aplicação
class BibliotecaDigitalApp extends StatelessWidget {
  const BibliotecaDigitalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider para autenticação
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => ServiceLocator.instance.createAuthProvider(),
        ),
        
        // Provider para livros
        ChangeNotifierProvider<BooksProvider>(
          create: (_) => ServiceLocator.instance.createBooksProvider(),
        ),
        
        // Provider para tema
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ServiceLocator.instance.createThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            
            // Configuração de tema
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.themeMode,
            
            // Configuração de rotas
            initialRoute: _getInitialRoute(context),
            routes: _getRoutes(),
            onGenerateRoute: _onGenerateRoute,
            
            // Builder para tratamento global de erros
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0), // Evita mudanças de escala
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }

  /// Determina a rota inicial baseada no estado de autenticação
  String _getInitialRoute(BuildContext context) {
    // Forçando a tela de login como inicial.
    return '/login';
  }

  /// Define as rotas da aplicação
  Map<String, WidgetBuilder> _getRoutes() {
    return {
      '/login': (context) => const LoginScreen(),
      '/home': (context) => const HomeScreen(),
      '/upload-book': (context) => const UploadBookScreen(),
    };
  }

  /// Gera rotas dinamicamente para rotas com parâmetros
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/book-reader':
        final bookId = settings.arguments as String?;
        if (bookId != null) {
          return MaterialPageRoute(
            builder: (context) => BookReaderScreen(bookId: bookId),
            settings: settings,
          );
        }
        break;
        
      case '/book-details':
        final bookId = settings.arguments as String?;
        if (bookId != null) {
          // TODO: Implementar tela de detalhes do livro se necessário
          return MaterialPageRoute(
            builder: (context) => BookReaderScreen(bookId: bookId),
            settings: settings,
          );
        }
        break;
    }
    
    // Rota não encontrada
    return MaterialPageRoute(
      builder: (context) => const _NotFoundScreen(),
      settings: settings,
    );
  }
}

/// Tela para rotas não encontradas
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página não encontrada'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Página não encontrada',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'A página que você está procurando não existe.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    );
  }
}
