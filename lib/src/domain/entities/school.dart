/// Entidade School - representa uma escola no sistema
class School {
  final String id;
  final String nome;
  final String email;
  final DateTime? createdAt;
  final bool? isActive;

  const School({
    required this.id,
    required this.nome,
    required this.email,
    this.createdAt,
    this.isActive,
  });

  factory School.fromMap(Map<String, dynamic> map) {
    return School(
      id: map['_id'] ?? map['id'] ?? '',
      nome: map['nome'] ?? map['name'] ?? '',
      email: map['email'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'])
          : null,
      isActive: map['isActive'],
    );
  }

  School copyWith({
    String? id,
    String? nome,
    String? email,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return School(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is School && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'School(id: $id, nome: $nome, email: $email)';
  }
}