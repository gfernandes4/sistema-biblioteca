import 'dart:io';

import '../entities/book.dart';

/// Interface do repositório de livros
abstract class BooksRepository {
  Future<List<Book>> getAllBooks({bool forceRefresh = false});
  Future<Book> getBookById(String id);
  Future<List<Book>> searchBooks(String query);
  Future<Book> uploadBook(File file, Map<String, String> bookData);
  Future<void> deleteBook(String id);
  Future<void> refreshCache();
}
