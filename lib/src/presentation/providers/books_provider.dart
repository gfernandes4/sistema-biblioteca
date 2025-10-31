import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/api_constants.dart';
import '../../domain/entities/book.dart';
import '../../domain/usecases/get_books_usecase.dart';
import '../../domain/usecases/search_books_usecase.dart';
import '../../domain/usecases/upload_book_usecase.dart';
import '../../domain/usecases/delete_book_usecase.dart';
import '../../core/errors/failures.dart';

import '../../domain/repositories/auth_repository.dart';

/// Estados possíveis da lista de livros
enum BooksState {
  initial,
  loading,
  loaded,
  error,
}

/// Provider para gerenciar estado dos livros
class BooksProvider extends ChangeNotifier {
  final GetBooksUseCase getBooksUseCase;
  final SearchBooksUseCase searchBooksUseCase;
  final UploadBookUseCase uploadBookUseCase;
  final DeleteBookUseCase deleteBookUseCase;
  final AuthRepository authRepository;

  BooksProvider({
    required this.getBooksUseCase,
    required this.searchBooksUseCase,
    required this.uploadBookUseCase,
    required this.deleteBookUseCase,
    required this.authRepository,
  });

  // Estado principal
  BooksState _state = BooksState.initial;
  List<Book> _books = [];
  String? _errorMessage;

  // Estado de busca
  BooksState _searchState = BooksState.initial;
  List<Book> _searchResults = [];
  String? _searchErrorMessage;
  String _currentSearchQuery = '';

  // Estado de upload
  bool _isUploading = false;
  String? _uploadErrorMessage;

  // Getters principais
  BooksState get state => _state;
  List<Book> get books => _books;
  String? get errorMessage => _errorMessage;

  // Getters de busca
  BooksState get searchState => _searchState;
  List<Book> get searchResults => _searchResults;
  String? get searchErrorMessage => _searchErrorMessage;
  String get currentSearchQuery => _currentSearchQuery;
  bool get hasSearchResults => _searchResults.isNotEmpty;

  // Getters de upload
  bool get isUploading => _isUploading;
  String? get uploadErrorMessage => _uploadErrorMessage;

  /// Baixa o arquivo de um livro e o salva localmente.
  /// Retorna o caminho do arquivo em caso de sucesso.
  /// Lança uma exceção [Failure] em caso de erro.
  Future<String> downloadBook(Book book) async {
    // [MODIFICAÇÃO DE AUTENTICAÇÃO]
    // Pega o token se estiver disponível, mas não falha se for nulo.
    final String? token = authRepository.getAuthToken();
    
    // Define os cabeçalhos (headers)
    final Map<String, String> headers = {};
    if (token != null) {
      // Adiciona o token apenas se ele existir
      headers['Authorization'] = 'Bearer $token';
    }

    // A verificação "if (token == null) { throw ... }" FOI REMOVIDA.

    try {
      final directory = await getApplicationDocumentsDirectory();
      
      // [CORREÇÃO DE BUG]
      // Garante que o nome do arquivo seja seguro, usando '/' 
      // como separador de URL/caminho remoto
      final fileName = book.filePath.split('/').last; 
      
      final filePath = '${directory.path}${Platform.pathSeparator}$fileName';
      final file = File(filePath);

      // [MELHORIA DE CACHE]
      // Se o arquivo já existe localmente, apenas retorna o caminho
      if (await file.exists()) {
        return filePath;
      }

      // Se não existe, faz o download
      final url = Uri.parse('${ApiConstants.baseUrl}/livros/${book.id}/arquivo');
      
      // [MODIFICAÇÃO DE AUTENTICAÇÃO]
      // Passa os 'headers' (que podem estar vazios ou conter o token)
      final response = await http.get(
        url,
        headers: headers, 
      );

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Se o *servidor* retornar 401 (talvez o livro não seja público)
        throw const UnauthorizedFailure(message: 'Você não tem permissão para baixar este livro.');
      } else {
        throw NetworkFailure(message: 'Falha no download. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw NetworkFailure(message: 'Erro inesperado durante o download: $e');
    }
  }

  /// Carrega todos os livros
  Future<void> loadBooks({bool forceRefresh = false}) async {
    _setState(BooksState.loading);
    _clearError();

    try {
      final loadedBooks = await getBooksUseCase(forceRefresh: forceRefresh);
      _books = loadedBooks;
      _setState(BooksState.loaded);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setState(BooksState.error);
    }
  }

  /// Busca livros por termo
  Future<void> searchBooks(String query) async {
    _currentSearchQuery = query;
    _setSearchState(BooksState.loading);
    _clearSearchError();

    try {
      final results = await searchBooksUseCase(query: query);
      _searchResults = results;
      _setSearchState(BooksState.loaded);
    } catch (e) {
      _setSearchError(_getErrorMessage(e));
      _setSearchState(BooksState.error);
    }
  }

  /// Limpa resultados de busca
  void clearSearch() {
    _searchResults = [];
    _currentSearchQuery = '';
    _searchErrorMessage = null;
    _setSearchState(BooksState.initial);
  }

  /// Faz upload de um novo livro
  Future<bool> uploadBook({
    required File file,
    required String title,
    required String author,
    required String category,
    String? description,
  }) async {
    _setUploading(true);
    _clearUploadError();

    try {
      final newBook = await uploadBookUseCase(
        file: file,
        title: title,
        author: author,
        category: category,
        description: description,
      );

      // Adicionar novo livro à lista local
      _books.insert(0, newBook);
      
      _setUploading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setUploadError(_getErrorMessage(e));
      _setUploading(false);
      return false;
    }
  }

  /// Deleta um livro
  Future<bool> deleteBook(String bookId) async {
    try {
      await deleteBookUseCase(bookId: bookId);
      
      // Remover livro da lista local
      _books.removeWhere((book) => book.id == bookId);
      _searchResults.removeWhere((book) => book.id == bookId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  /// Filtra livros por categoria
  List<Book> getBooksByCategory(String category) {
    return _books.where((book) => book.category == category).toList();
  }

  /// Retorna livro por ID
  Book? getBookById(String id) {
    try {
      return _books.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }

  // === Métodos privados para gerenciar estado ===

  void _setState(BooksState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setSearchState(BooksState newState) {
    _searchState = newState;
    notifyListeners();
  }

  void _setSearchError(String error) {
    _searchErrorMessage = error;
    notifyListeners();
  }

  void _clearSearchError() {
    _searchErrorMessage = null;
    notifyListeners();
  }

  void _setUploading(bool uploading) {
    _isUploading = uploading;
    notifyListeners();
  }

  void _setUploadError(String error) {
    _uploadErrorMessage = error;
    notifyListeners();
  }

  void _clearUploadError() {
    _uploadErrorMessage = null;
    notifyListeners();
  }

  /// Limpa erros manualmente (para UI)
  void clearError() => _clearError();
  void clearSearchError() => _clearSearchError();
  void clearUploadError() => _clearUploadError();

  /// Converte exceção em mensagem amigável
  String _getErrorMessage(dynamic error) {
    if (error is Failure) {
      return error.message;
    }
    return 'Erro inesperado: $error';
  }
}