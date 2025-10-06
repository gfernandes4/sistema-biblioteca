import 'dart:io';

import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/book_model.dart';

/// DataSource remoto para livros
abstract class BooksRemoteDataSource {
  Future<List<BookModel>> getAllBooks();
  Future<BookModel> getBookById(String id);
  Future<List<BookModel>> searchBooks(String query);
  Future<BookModel> uploadBook(File file, Map<String, String> bookData);
  Future<void> deleteBook(String id);
  Future<List<Map<String, dynamic>>> getChanges({String? since});
}

class BooksRemoteDataSourceImpl implements BooksRemoteDataSource {
  final ApiService apiService;

  BooksRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<BookModel>> getAllBooks() async {
    final response = await apiService.get(ApiConstants.booksEndpoint) as List<dynamic>;
    
    return response
        .map((bookJson) => BookModel.fromJson(bookJson as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BookModel> getBookById(String id) async {
    final response = await apiService.get('${ApiConstants.booksEndpoint}/$id') as Map<String, dynamic>;
    // Backend returns the book object directly
    return BookModel.fromJson(response);
  }

  @override
  Future<List<BookModel>> searchBooks(String query) async {
    // Backend implements search via GET /livros?titulo=...
    final response = await apiService.get(
      ApiConstants.searchEndpoint,
      queryParameters: {'titulo': query},
    ) as List<dynamic>;
    
    return response
        .map((bookJson) => BookModel.fromJson(bookJson as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BookModel> uploadBook(File file, Map<String, String> bookData) async {
    // backend returns {'message': ..., 'livro_id': id} on success
    final response = await apiService.uploadFile(
      ApiConstants.uploadEndpoint,
      file,
      fields: {
        'titulo': bookData['title'] ?? bookData['titulo'] ?? '',
        'autor': bookData['author'] ?? bookData['autor'] ?? '',
        'categoria': bookData['category'] ?? bookData['categoria'] ?? '',
      },
    ) as Map<String, dynamic>;

    final livroId = response['livro_id']?.toString();
    if (livroId == null) {
      throw Exception('Resposta inesperada do servidor ao enviar livro');
    }

    // Buscar os detalhes do livro criado
    return await getBookById(livroId);
  }

  @override
  Future<void> deleteBook(String id) async {
    await apiService.delete('${ApiConstants.booksEndpoint}/$id/remover');
  }

  @override
  Future<List<Map<String, dynamic>>> getChanges({String? since}) async {
    final response = await apiService.get(
      ApiConstants.changesEndpoint,
      queryParameters: since != null ? {'since': since} : null,
    ) as List<dynamic>;

    return response.map((r) => r as Map<String, dynamic>).toList();
  }
}
