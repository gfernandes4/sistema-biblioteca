import '../../data/repositories/books_repository_impl.dart';
import '../../core/errors/failures.dart';

/// Use case para deletar livro
class DeleteBookUseCase {
  final BooksRepository booksRepository;

  DeleteBookUseCase({required this.booksRepository});

  /// Deleta um livro
  /// 
  /// Parâmetros:
  /// - [bookId]: ID do livro a ser deletado
  Future<void> call({required String bookId}) async {
    // Validação básica
    if (bookId.trim().isEmpty) {
      throw const ValidationFailure(message: 'ID do livro é obrigatório');
    }
    
    await booksRepository.deleteBook(bookId.trim());
  }
}
