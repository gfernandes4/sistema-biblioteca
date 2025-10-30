import '../entities/school.dart';

/// Interface do repositório de escolas
abstract class SchoolRepository {
  /// Lista todas as escolas
  Future<List<School>> getSchools();
  
  /// Busca escola por ID
  Future<School> getSchoolById(String id);
  
  /// Cria nova escola
  Future<School> createSchool({
    required String nome,
    required String email,
    required String senha,
  });
  
  /// Atualiza escola existente
  Future<School> updateSchool({
    required String id,
    required String nome,
    required String email,
    String? senha, // Opcional - só atualiza se fornecida
  });
  
  /// Remove escola
  Future<void> deleteSchool(String id);
}