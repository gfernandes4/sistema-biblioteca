/// Entidade Book - representa um livro no sistema
class Book {
  final String id;
  final String title;
  final String author;
  final String? description;
  final String category;
  final String? imageUrl;
  final String filePath; // Caminho do arquivo PDF/EPUB
  final String fileFormat; // pdf ou epub
  final int fileSizeBytes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isAvailable;
  final String? uploadedBy; // ID do usuário que fez o upload

  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.description,
    required this.category,
    this.imageUrl,
    required this.filePath,
    required this.fileFormat,
    required this.fileSizeBytes,
    required this.createdAt,
    required this.updatedAt,
    required this.isAvailable,
    this.uploadedBy,
  });

  Book copyWith({
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
    return Book(
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

  /// Retorna o tamanho do arquivo formatado (ex: 5.2 MB)
  String get formattedFileSize {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Verifica se o formato do arquivo é suportado
  bool get isSupportedFormat {
    return ['pdf', 'epub'].contains(fileFormat.toLowerCase());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Book && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Book(id: $id, title: $title, author: $author, format: $fileFormat)';
  }
}

/// Categorias predefinidas de livros
class BookCategories {
  static const String fiction = 'Ficção';
  static const String nonFiction = 'Não-ficção';
  static const String science = 'Ciências';
  static const String history = 'História';
  static const String literature = 'Literatura';
  static const String mathematics = 'Matemática';
  static const String geography = 'Geografia';
  static const String biology = 'Biologia';
  static const String physics = 'Física';
  static const String chemistry = 'Química';
  static const String portuguese = 'Português';
  static const String english = 'Inglês';
  static const String philosophy = 'Filosofia';
  static const String sociology = 'Sociologia';
  static const String arts = 'Artes';
  static const String other = 'Outros';

  static const List<String> all = [
    fiction,
    nonFiction,
    science,
    history,
    literature,
    mathematics,
    geography,
    biology,
    physics,
    chemistry,
    portuguese,
    english,
    philosophy,
    sociology,
    arts,
    other,
  ];
}
