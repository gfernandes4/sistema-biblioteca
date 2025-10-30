import '../entities/school.dart';
import '../repositories/school_repository.dart';

/// UseCase para obter todas as escolas
class GetSchoolsUseCase {
  final SchoolRepository repository;

  GetSchoolsUseCase({required this.repository});

  Future<List<School>> call() async {
    return await repository.getSchools();
  }
}

/// UseCase para obter escola por ID
class GetSchoolByIdUseCase {
  final SchoolRepository repository;

  GetSchoolByIdUseCase({required this.repository});

  Future<School> call({required String id}) async {
    return await repository.getSchoolById(id);
  }
}

/// UseCase para criar nova escola
class CreateSchoolUseCase {
  final SchoolRepository repository;

  CreateSchoolUseCase({required this.repository});

  Future<School> call({
    required String nome,
    required String email,
    required String senha,
  }) async {
    // Validações básicas
    if (nome.trim().isEmpty) {
      throw ArgumentError('Nome da escola é obrigatório');
    }
    
    if (email.trim().isEmpty || !email.contains('@')) {
      throw ArgumentError('Email inválido');
    }
    
    if (senha.length < 6) {
      throw ArgumentError('Senha deve ter no mínimo 6 caracteres');
    }
    
    return await repository.createSchool(
      nome: nome.trim(),
      email: email.trim().toLowerCase(),
      senha: senha,
    );
  }
}

/// UseCase para atualizar escola
class UpdateSchoolUseCase {
  final SchoolRepository repository;

  UpdateSchoolUseCase({required this.repository});

  Future<School> call({
    required String id,
    required String nome,
    required String email,
    String? senha,
  }) async {
    // Validações básicas
    if (nome.trim().isEmpty) {
      throw ArgumentError('Nome da escola é obrigatório');
    }
    
    if (email.trim().isEmpty || !email.contains('@')) {
      throw ArgumentError('Email inválido');
    }
    
    if (senha != null && senha.isNotEmpty && senha.length < 6) {
      throw ArgumentError('Senha deve ter no mínimo 6 caracteres');
    }
    
    return await repository.updateSchool(
      id: id,
      nome: nome.trim(),
      email: email.trim().toLowerCase(),
      senha: senha,
    );
  }
}

/// UseCase para deletar escola
class DeleteSchoolUseCase {
  final SchoolRepository repository;

  DeleteSchoolUseCase({required this.repository});

  Future<void> call({required String id}) async {
    return await repository.deleteSchool(id);
  }
}