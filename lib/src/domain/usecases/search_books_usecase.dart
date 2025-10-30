import '../entities/book.dart';
import '../repositories/books_repository.dart';
import '../../core/errors/failures.dart';

/// Use case para buscar livros
class SearchBooksUseCase {
  final BooksRepository booksRepository;

  SearchBooksUseCase({required this.booksRepository});

  /// Busca livros por termo
  /// 
  /// Parâmetros:
  /// - [query]: Termo de busca (título, autor, categoria)
  /// 
  /// Retorna: Lista de livros que correspondem à busca
  Future<List<Book>> call({required String query}) async {
    // Validação básica
    if (query.trim().isEmpty) {
      throw const ValidationFailure(message: 'Termo de busca é obrigatório');
    }
    
    if (query.trim().length < 2) {
      throw const ValidationFailure(
        message: 'Termo de busca deve ter pelo menos 2 caracteres'
      );
    }
    
    return await booksRepository.searchBooks(query.trim());
  }
}
