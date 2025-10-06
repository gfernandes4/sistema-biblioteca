import '../../domain/entities/user.dart';

/// Modelo de User para serialização/deserialização
class UserModel extends User {
  const UserModel({
    required String id,
    required UserType type,
    String? name,
    String? email,
    String? schoolId,
    DateTime? createdAt,
    bool? isActive,
  }) : super(
          id: id,
          type: type,
          name: name,
          email: email,
          schoolId: schoolId,
          createdAt: createdAt,
          isActive: isActive,
        );

  /// Cria UserModel a partir de JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      type: UserTypeExtension.fromString(json['type'] as String),
      schoolId: json['school_id'] as String?,
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool?,
    );
  }

  /// Converte UserModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': type.value,
      'school_id': schoolId,
      'created_at': createdAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Cria UserModel a partir de User entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      type: user.type,
      name: user.name,
      email: user.email,
      schoolId: user.schoolId,
      createdAt: user.createdAt,
      isActive: user.isActive,
    );
  }

  /// Converte para User entity
  User toEntity() {
    return User(
      id: id,
      type: type,
      name: name,
      email: email,
      schoolId: schoolId,
      createdAt: createdAt,
      isActive: isActive,
    );
  }

  @override
  UserModel copyWith({
    String? id,
    UserType? type,
    String? name,
    String? email,
    String? schoolId,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      email: email ?? this.email,
      schoolId: schoolId ?? this.schoolId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
