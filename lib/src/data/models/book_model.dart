import '../../domain/entities/book.dart';

/// Modelo de Book para serialização/deserialização
class BookModel extends Book {
  const BookModel({
    required String id,
    required String title,
    required String author,
    String? description,
    required String category,
    String? imageUrl,
    required String filePath,
    required String fileFormat,
    required int fileSizeBytes,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isAvailable,
    String? uploadedBy,
  }) : super(
          id: id,
          title: title,
          author: author,
          description: description,
          category: category,
          imageUrl: imageUrl,
          filePath: filePath,
          fileFormat: fileFormat,
          fileSizeBytes: fileSizeBytes,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isAvailable: isAvailable,
          uploadedBy: uploadedBy,
        );

  /// Cria BookModel a partir de JSON
  factory BookModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse dates that could be String, int, or null
    DateTime _safeParseDateTime(dynamic value) {
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      // Return epoch as a fallback if the value is null or an unexpected type
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return BookModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Título desconhecido',
      author: json['author'] as String? ?? 'Autor desconhecido',
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'Sem categoria',
      imageUrl: json['image_url'] as String?,
      filePath: json['file_path'] as String? ?? '',
      fileFormat: json['file_format'] as String? ?? 'unknown',
      fileSizeBytes: json['file_size_bytes'] as int? ?? 0,
      createdAt: _safeParseDateTime(json['created_at']),
      updatedAt: _safeParseDateTime(json['updated_at']),
      isAvailable: json['is_available'] as bool? ?? true,
      uploadedBy: json['uploaded_by'] as String?,
    );
  }

  /// Converte BookModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'category': category,
      'image_url': imageUrl,
      'file_path': filePath,
      'file_format': fileFormat,
      'file_size_bytes': fileSizeBytes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_available': isAvailable,
      'uploaded_by': uploadedBy,
    };
  }

  /// Cria BookModel a partir de Book entity
  factory BookModel.fromEntity(Book book) {
    return BookModel(
      id: book.id,
      title: book.title,
      author: book.author,
      description: book.description,
      category: book.category,
      imageUrl: book.imageUrl,
      filePath: book.filePath,
      fileFormat: book.fileFormat,
      fileSizeBytes: book.fileSizeBytes,
      createdAt: book.createdAt,
      updatedAt: book.updatedAt,
      isAvailable: book.isAvailable,
      uploadedBy: book.uploadedBy,
    );
  }

  /// Converte para Book entity
  Book toEntity() {
    return Book(
      id: id,
      title: title,
      author: author,
      description: description,
      category: category,
      imageUrl: imageUrl,
      filePath: filePath,
      fileFormat: fileFormat,
      fileSizeBytes: fileSizeBytes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isAvailable: isAvailable,
      uploadedBy: uploadedBy,
    );
  }

  /// Cria BookModel para inserção no banco local (SQLite)
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'category': category,
      'image_url': imageUrl,
      'file_path': filePath,
      'file_format': fileFormat,
      'file_size_bytes': fileSizeBytes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_available': isAvailable ? 1 : 0,
      'uploaded_by': uploadedBy,
    };
  }

  /// Cria BookModel a partir de dados do SQLite
  factory BookModel.fromSqlite(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      imageUrl: map['image_url'] as String?,
      filePath: map['file_path'] as String,
      fileFormat: map['file_format'] as String,
      fileSizeBytes: map['file_size_bytes'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isAvailable: (map['is_available'] as int) == 1,
      uploadedBy: map['uploaded_by'] as String?,
    );
  }

  @override
  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? category,
    String? imageUrl,
    String? filePath,
    String? fileFormat,
    int? fileSizeBytes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAvailable,
    String? uploadedBy,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      filePath: filePath ?? this.filePath,
      fileFormat: fileFormat ?? this.fileFormat,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAvailable: isAvailable ?? this.isAvailable,
      uploadedBy: uploadedBy ?? this.uploadedBy,
    );
  }
}
