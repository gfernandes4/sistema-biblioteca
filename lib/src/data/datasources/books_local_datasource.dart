import '../../core/services/database_service.dart';
import '../models/book_model.dart';

/// DataSource local para livros (cache SQLite)
abstract class BooksLocalDataSource {
  Future<List<BookModel>> getAllBooks();
  Future<BookModel?> getBookById(String id);
  Future<List<BookModel>> searchBooks(String query);
  Future<void> cacheBook(BookModel book);
  Future<void> cacheBooks(List<BookModel> books);
  Future<void> deleteBook(String id);
  Future<void> clearCache();
  Future<String?> getSetting(String key);
  Future<void> saveSetting(String key, String value);
}

class BooksLocalDataSourceImpl implements BooksLocalDataSource {
  final DatabaseService databaseService;

  BooksLocalDataSourceImpl({required this.databaseService});

  @override
  Future<List<BookModel>> getAllBooks() async {
    final booksData = await databaseService.getAllBooks();
    return booksData.map((bookMap) => BookModel.fromSqlite(bookMap)).toList();
  }

  @override
  Future<BookModel?> getBookById(String id) async {
    final bookData = await databaseService.getBookById(id);
    if (bookData == null) return null;
    return BookModel.fromSqlite(bookData);
  }

  @override
  Future<List<BookModel>> searchBooks(String query) async {
    final booksData = await databaseService.searchBooks(query);
    return booksData.map((bookMap) => BookModel.fromSqlite(bookMap)).toList();
  }

  @override
  Future<void> cacheBook(BookModel book) async {
    await databaseService.insertBook(book.toSqlite());
  }

  @override
  Future<void> cacheBooks(List<BookModel> books) async {
    for (final book in books) {
      await cacheBook(book);
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    await databaseService.deleteBook(id);
  }

  @override
  Future<void> clearCache() async {
    await databaseService.clearBooksCache();
  }

  @override
  Future<String?> getSetting(String key) async {
    return await databaseService.getSetting(key);
  }

  @override
  Future<void> saveSetting(String key, String value) async {
    await databaseService.saveSetting(key, value);
  }
}
