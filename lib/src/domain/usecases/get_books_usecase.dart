import '../entities/book.dart';
import '../../data/repositories/books_repository_impl.dart';

/// Use case para buscar todos os livros
class GetBooksUseCase {
  final BooksRepository booksRepository;

  GetBooksUseCase({required this.booksRepository});

  /// Busca todos os livros
  /// 
  /// Parâmetros:
  /// - [forceRefresh]: Se true, força busca da API ignorando cache
  /// 
  /// Retorna: Lista de livros
  Future<List<Book>> call({bool forceRefresh = false}) async {
    return await booksRepository.getAllBooks(forceRefresh: forceRefresh);
  }
}
