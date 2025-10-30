import 'dart:io';

import '../entities/book.dart';
import '../repositories/books_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/constants/app_constants.dart';

/// Use case para fazer upload de livro
class UploadBookUseCase {
  final BooksRepository booksRepository;

  UploadBookUseCase({required this.booksRepository});

  /// Faz upload de um novo livro
  /// 
  /// Parâmetros:
  /// - [file]: Arquivo do livro (PDF ou EPUB)
  /// - [title]: Título do livro
  /// - [author]: Autor do livro
  /// - [category]: Categoria do livro
  /// - [description]: Descrição opcional do livro
  /// 
  /// Retorna: Livro criado
  Future<Book> call({
    required File file,
    required String title,
    required String author,
    required String category,
    String? description,
  }) async {
    // Validações
    _validateFile(file);
    _validateBookData(title, author, category);
    
    // Preparar dados do livro
    final bookData = {
      'title': title.trim(),
      'author': author.trim(),
      'category': category.trim(),
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
    };
    
    // Fazer upload
    return await booksRepository.uploadBook(file, bookData);
  }

  /// Valida o arquivo
  void _validateFile(File file) {
    // Verificar se arquivo existe
    if (!file.existsSync()) {
      throw const ValidationFailure(message: 'Arquivo não encontrado');
    }
    
    // Verificar tamanho do arquivo
    final fileSize = file.lengthSync();
    if (fileSize > AppConstants.maxFileSize) {
      final maxSizeMB = AppConstants.maxFileSize / (1024 * 1024);
      throw ValidationFailure(
        message: 'Arquivo muito grande. Tamanho máximo: ${maxSizeMB}MB'
      );
    }
    
    // Verificar extensão
    final extension = file.path.split('.').last.toLowerCase();
    if (!AppConstants.supportedBookFormats.contains(extension)) {
      throw ValidationFailure(
        message: 'Formato não suportado. Formatos aceitos: ${AppConstants.supportedBookFormats.join(', ')}'
      );
    }
  }

  /// Valida dados do livro
  void _validateBookData(String title, String author, String category) {
    if (title.trim().isEmpty) {
      throw const ValidationFailure(message: 'Título é obrigatório');
    }
    
    if (title.trim().length < 2) {
      throw const ValidationFailure(
        message: 'Título deve ter pelo menos 2 caracteres'
      );
    }
    
    if (author.trim().isEmpty) {
      throw const ValidationFailure(message: 'Autor é obrigatório');
    }
    
    if (author.trim().length < 2) {
      throw const ValidationFailure(
        message: 'Nome do autor deve ter pelo menos 2 caracteres'
      );
    }
    
    if (category.trim().isEmpty) {
      throw const ValidationFailure(message: 'Categoria é obrigatória');
    }
  }
}
