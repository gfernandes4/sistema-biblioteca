import '../../domain/entities/school.dart';
import '../../domain/repositories/school_repository.dart';
import '../datasources/school_remote_datasource.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';

/// Implementação do repositório de escolas.
class SchoolRepositoryImpl implements SchoolRepository {
  final SchoolRemoteDataSource remoteDataSource;

  SchoolRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<School>> getSchools() async {
    try {
      final schools = await remoteDataSource.getSchools();
      print('📚 Repository: ${schools.length} escolas carregadas');
      return schools;
    } on ServerException catch (e) {
      print('❌ ServerException em getSchools: ${e.message}');
      throw ServerFailure(message: e.message);
    } catch (e) {
      print('❌ Erro genérico em getSchools: $e');
      throw GenericFailure(message: 'Erro inesperado ao buscar escolas: $e');
    }
  }

  @override
  Future<School> createSchool({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final school = await remoteDataSource.createSchool(
        nome: nome,
        email: email,
        senha: senha,
      );
      print('✅ Repository: Escola "${school.nome}" criada com sucesso');
      return school;
    } on ServerException catch (e) {
      print('❌ ServerException em createSchool: ${e.message}');
      throw ServerFailure(message: e.message);
    } catch (e) {
      print('❌ Erro genérico em createSchool: $e');
      throw GenericFailure(message: 'Erro inesperado ao criar escola: $e');
    }
  }

  @override
  Future<void> deleteSchool(String id) async {
    try {
      await remoteDataSource.deleteSchool(id);
      print('✅ Repository: Escola $id deletada com sucesso');
    } on ServerException catch (e) {
      print('❌ ServerException em deleteSchool: ${e.message}');
      throw ServerFailure(message: e.message);
    } catch (e) {
      print('❌ Erro genérico em deleteSchool: $e');
      throw GenericFailure(message: 'Erro inesperado ao deletar escola: $e');
    }
  }
  
  @override
  Future<School> getSchoolById(String id) async {
    // TODO: Implementar quando o backend tiver o endpoint
    throw UnimplementedError('Método getSchoolById ainda não implementado');
  }

  @override
  Future<School> updateSchool({
    required String id,
    required String nome,
    required String email,
    String? senha,
  }) async {
    // TODO: Implementar quando o backend tiver o endpoint
    throw UnimplementedError('Método updateSchool ainda não implementado');
  }
}