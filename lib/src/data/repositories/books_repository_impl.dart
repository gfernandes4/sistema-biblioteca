import 'dart:io';

import '../../domain/entities/book.dart';
import '../../core/errors/failures.dart';
import '../datasources/books_remote_datasource.dart';
import '../datasources/books_local_datasource.dart';

/// Interface do repositório de livros
abstract class BooksRepository {
  Future<List<Book>> getAllBooks({bool forceRefresh = false});
  Future<Book> getBookById(String id);
  Future<List<Book>> searchBooks(String query);
  Future<Book> uploadBook(File file, Map<String, String> bookData);
  Future<void> deleteBook(String id);
  Future<void> refreshCache();
}

/// Implementação do repositório de livros
class BooksRepositoryImpl implements BooksRepository {
  final BooksRemoteDataSource remoteDataSource;
  final BooksLocalDataSource localDataSource;

  BooksRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Book>> getAllBooks({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        // Buscar da API e atualizar cache
        final remoteBooksModels = await remoteDataSource.getAllBooks();
        
        // Limpar cache antigo e salvar novos dados
        await localDataSource.clearCache();
        await localDataSource.cacheBooks(remoteBooksModels);
        
        return remoteBooksModels.map((model) => model.toEntity()).toList();
      } else {
        // Tentar buscar do cache primeiro
        final localBooksModels = await localDataSource.getAllBooks();
        // Tentar sincronizar deltas antes de retornar cache
        try {
          final lastSync = await localDataSource.getSetting('last_sync');
          final changes = await remoteDataSource.getChanges(since: lastSync);
          if (changes.isNotEmpty) {
            // Aplicar mudanças
            for (final change in changes) {
              final action = change['action'] as String? ?? '';
              final livroId = change['livro_id']?.toString();
              if (livroId == null) continue;
              if (action == 'delete') {
                await localDataSource.deleteBook(livroId);
              } else if (action == 'create') {
                try {
                  final bookModel = await remoteDataSource.getBookById(livroId);
                  await localDataSource.cacheBook(bookModel);
                } catch (_) {
                  // ignore
                }
              }
            }
            // Atualizar last_sync para agora
            await localDataSource.saveSetting('last_sync', DateTime.now().toIso8601String());
            // Recarregar cache após aplicar mudanças
            final refreshedLocal = await localDataSource.getAllBooks();
            return refreshedLocal.map((model) => model.toEntity()).toList();
          }
        } catch (_) {
          // Se sincronização falhar, apenas retornar cache local
        }

        if (localBooksModels.isNotEmpty) {
          return localBooksModels.map((model) => model.toEntity()).toList();
        } else {
          // Cache vazio, buscar da API
          return await getAllBooks(forceRefresh: true);
        }
      }
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      
      // Se a API falhar, tentar retornar dados do cache
      try {
        final localBooksModels = await localDataSource.getAllBooks();
        if (localBooksModels.isNotEmpty) {
          return localBooksModels.map((model) => model.toEntity()).toList();
        }
      } catch (_) {
        // Ignorar erro do cache local
      }
      
      throw NetworkFailure(message: 'Erro ao carregar livros: $e');
    }
  }

  @override
  Future<Book> getBookById(String id) async {
    try {
      // Tentar buscar do cache primeiro
      final localBookModel = await localDataSource.getBookById(id);
      if (localBookModel != null) {
        return localBookModel.toEntity();
      }
      
      // Se não estiver no cache, buscar da API
      final remoteBookModel = await remoteDataSource.getBookById(id);
      
      // Cachear o livro para próximas consultas
      await localDataSource.cacheBook(remoteBookModel);
      
      return remoteBookModel.toEntity();
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw NetworkFailure(message: 'Erro ao carregar livro: $e');
    }
  }

  @override
  Future<List<Book>> searchBooks(String query) async {
    try {
      // Buscar da API primeiro para ter resultados mais atualizados
      final remoteBooksModels = await remoteDataSource.searchBooks(query);
      
      // Cachear os resultados
      for (final book in remoteBooksModels) {
        await localDataSource.cacheBook(book);
      }
      
      return remoteBooksModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      // Se a API falhar, buscar no cache local
      try {
        final localBooksModels = await localDataSource.searchBooks(query);
        return localBooksModels.map((model) => model.toEntity()).toList();
      } catch (_) {
        // Se o cache local também falhar
        if (e is Failure) {
          rethrow;
        }
        throw NetworkFailure(message: 'Erro na busca de livros: $e');
      }
    }
  }

  @override
  Future<Book> uploadBook(File file, Map<String, String> bookData) async {
    try {
      final bookModel = await remoteDataSource.uploadBook(file, bookData);
      
      // Cachear o novo livro
      await localDataSource.cacheBook(bookModel);
      
      return bookModel.toEntity();
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw BookUploadFailure(message: 'Erro no upload do livro: $e');
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    try {
      // Deletar da API
      await remoteDataSource.deleteBook(id);
      
      // Remover do cache local
      await localDataSource.deleteBook(id);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw NetworkFailure(message: 'Erro ao deletar livro: $e');
    }
  }

  @override
  Future<void> refreshCache() async {
    try {
      final remoteBooksModels = await remoteDataSource.getAllBooks();
      await localDataSource.clearCache();
      await localDataSource.cacheBooks(remoteBooksModels);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw NetworkFailure(message: 'Erro ao atualizar cache: $e');
    }
  }
}
