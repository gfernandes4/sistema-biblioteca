import '../../domain/entities/school.dart';

/// Modelo de School para serialização/deserialização
class SchoolModel extends School {
  const SchoolModel({
    required String id,
    required String nome,
    required String email,
    DateTime? createdAt,
    bool? isActive,
  }) : super(
          id: id,
          nome: nome,
          email: email,
          createdAt: createdAt,
          isActive: isActive,
        );

  /// Cria SchoolModel a partir de JSON
  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] as String? ?? '',
      email: json['email'] as String? ?? '',
      createdAt: json['criado_em'] != null
          ? DateTime.tryParse(json['criado_em'] as String)
          : null,
      isActive: json['ativo'] as bool? ?? true,
    );
  }

  /// Converte SchoolModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'criado_em': createdAt?.toIso8601String(),
      'ativo': isActive,
    };
  }

  /// Converte para JSON para criar/atualizar escola (inclui senha)
  Map<String, dynamic> toCreateJson(String senha) {
    return {
      'nome': nome,
      'email': email,
      'senha': senha,
    };
  }

  /// Converte para JSON para atualizar escola (sem senha se não for alterada)
  Map<String, dynamic> toUpdateJson({String? senha}) {
    final json = {
      'nome': nome,
      'email': email,
    };
    
    if (senha != null && senha.isNotEmpty) {
      json['senha'] = senha;
    }
    
    return json;
  }

  /// Cria SchoolModel a partir de School entity
  factory SchoolModel.fromEntity(School school) {
    return SchoolModel(
      id: school.id,
      nome: school.nome,
      email: school.email,
      createdAt: school.createdAt,
      isActive: school.isActive,
    );
  }

  /// Converte para School entity
  School toEntity() {
    return School(
      id: id,
      nome: nome,
      email: email,
      createdAt: createdAt,
      isActive: isActive,
    );
  }

  @override
  SchoolModel copyWith({
    String? id,
    String? nome,
    String? email,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return SchoolModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}