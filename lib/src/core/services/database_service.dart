import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';
import '../errors/failures.dart';

/// Serviço para gerenciamento do banco de dados local (SQLite)
class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;
  final Logger _logger = Logger();

  DatabaseService._internal();

  factory DatabaseService() {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  /// Retorna a instância do banco de dados
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa o banco de dados
  Future<Database> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final dbPath = path.join(databasesPath, AppConstants.databaseName);

      _logger.d('Inicializando banco de dados em: $dbPath');

      return await openDatabase(
        dbPath,
        version: AppConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      _logger.e('Erro ao inicializar banco de dados: $e');
      throw DatabaseFailure(message: 'Erro ao inicializar banco: $e');
    }
  }

  /// Cria as tabelas do banco
  Future<void> _onCreate(Database db, int version) async {
    try {
      _logger.d('Criando tabelas do banco de dados');

      // Tabela de livros para cache offline
      await db.execute('''
        CREATE TABLE books (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          author TEXT NOT NULL,
          description TEXT,
          category TEXT NOT NULL,
          image_url TEXT,
          file_path TEXT NOT NULL,
          file_format TEXT NOT NULL,
          file_size_bytes INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          is_available INTEGER NOT NULL DEFAULT 1,
          uploaded_by TEXT,
          is_cached INTEGER NOT NULL DEFAULT 0
        )
      ''');

      // Tabela de usuários (cache limitado)
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT NOT NULL,
          type TEXT NOT NULL,
          school_id TEXT,
          created_at INTEGER NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1
        )
      ''');

      // Tabela de configurações locais
      await db.execute('''
        CREATE TABLE settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      _logger.d('Tabelas criadas com sucesso');
    } catch (e) {
      _logger.e('Erro ao criar tabelas: $e');
      throw DatabaseFailure(message: 'Erro ao criar tabelas: $e');
    }
  }

  /// Atualiza o banco de dados
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.d('Atualizando banco de dados de $oldVersion para $newVersion');
    // Implementar migrations quando necessário
  }

  /// Inserir livro
  Future<void> insertBook(Map<String, dynamic> book) async {
    try {
      final db = await database;
      await db.insert(
        'books',
        book,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      _logger.e('Erro ao inserir livro: $e');
      throw DatabaseFailure(message: 'Erro ao salvar livro: $e');
    }
  }

  /// Buscar todos os livros
  Future<List<Map<String, dynamic>>> getAllBooks() async {
    try {
      final db = await database;
      return await db.query('books', orderBy: 'title ASC');
    } catch (e) {
      _logger.e('Erro ao buscar livros: $e');
      throw DatabaseFailure(message: 'Erro ao carregar livros: $e');
    }
  }

  /// Buscar livro por ID
  Future<Map<String, dynamic>?> getBookById(String id) async {
    try {
      final db = await database;
      final results = await db.query(
        'books',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      _logger.e('Erro ao buscar livro por ID: $e');
      throw DatabaseFailure(message: 'Erro ao carregar livro: $e');
    }
  }

  /// Buscar livros por título, autor ou categoria
  Future<List<Map<String, dynamic>>> searchBooks(String query) async {
    try {
      final db = await database;
      final searchTerm = '%$query%';
      return await db.query(
        'books',
        where: 'title LIKE ? OR author LIKE ? OR category LIKE ?',
        whereArgs: [searchTerm, searchTerm, searchTerm],
        orderBy: 'title ASC',
      );
    } catch (e) {
      _logger.e('Erro ao buscar livros: $e');
      throw DatabaseFailure(message: 'Erro na busca: $e');
    }
  }

  /// Atualizar livro
  Future<void> updateBook(String id, Map<String, dynamic> book) async {
    try {
      final db = await database;
      await db.update(
        'books',
        book,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      _logger.e('Erro ao atualizar livro: $e');
      throw DatabaseFailure(message: 'Erro ao atualizar livro: $e');
    }
  }

  /// Deletar livro
  Future<void> deleteBook(String id) async {
    try {
      final db = await database;
      await db.delete(
        'books',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      _logger.e('Erro ao deletar livro: $e');
      throw DatabaseFailure(message: 'Erro ao deletar livro: $e');
    }
  }

  /// Limpar cache de livros
  Future<void> clearBooksCache() async {
    try {
      final db = await database;
      await db.delete('books');
      _logger.d('Cache de livros limpo');
    } catch (e) {
      _logger.e('Erro ao limpar cache: $e');
      throw DatabaseFailure(message: 'Erro ao limpar cache: $e');
    }
  }

  /// Salvar configuração
  Future<void> saveSetting(String key, String value) async {
    try {
      final db = await database;
      await db.insert(
        'settings',
        {
          'key': key,
          'value': value,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      _logger.e('Erro ao salvar configuração: $e');
      throw DatabaseFailure(message: 'Erro ao salvar configuração: $e');
    }
  }

  /// Buscar configuração
  Future<String?> getSetting(String key) async {
    try {
      final db = await database;
      final results = await db.query(
        'settings',
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      return results.isNotEmpty ? results.first['value'] as String : null;
    } catch (e) {
      _logger.e('Erro ao buscar configuração: $e');
      return null;
    }
  }

  /// Busca configuração e converte para Map caso armazene JSON (helper adicional)
  Future<Map<String, dynamic>?> getSettingAsMap(String key) async {
    final val = await getSetting(key);
    if (val == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(val) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Fecha a conexão com o banco
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
