/// Entidade User - representa um usuário do sistema
class User {
  final String id;
  final String? name;
  final String? email;
  final UserType type;
  final String? schoolId; // Para usuários do tipo escola
  final DateTime? createdAt;
  final bool? isActive;

  const User({
    required this.id,
    required this.type,
    this.name,
    this.email,
    this.schoolId,
    this.createdAt,
    this.isActive,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserType? type,
    String? schoolId,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      email: email ?? this.email,
      schoolId: schoolId ?? this.schoolId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, type: $type)';
  }
}

/// Tipos de usuário do sistema
enum UserType {
  admin,
  school,
  student,
}

/// Extensão para facilitar conversões
extension UserTypeExtension on UserType {
  String get name {
    switch (this) {
      case UserType.admin:
        return 'Admin';
      case UserType.school:
        return 'Escola';
      case UserType.student:
        return 'Aluno';
    }
  }

  String get value {
    switch (this) {
      case UserType.admin:
        return 'admin';
      case UserType.school:
        return 'school';
      case UserType.student:
        return 'student';
    }
  }

  static UserType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'admin':
        return UserType.admin;
      case 'escola':
        return UserType.school;
      case 'student':
        return UserType.student;
      default:
        throw ArgumentError('Tipo de usuário inválido: $type');
    }
  }
}
