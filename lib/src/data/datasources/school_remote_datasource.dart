import '../../domain/entities/school.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';

/// Contrato para o data source remoto de escolas.
abstract class SchoolRemoteDataSource {
  Future<List<School>> getSchools();
  Future<School> createSchool({
    required String nome,
    required String email,
    required String senha,
  });
  Future<void> deleteSchool(String id);
}

/// Implementação do data source remoto de escolas.
class SchoolRemoteDataSourceImpl implements SchoolRemoteDataSource {
  final ApiService apiService;

  SchoolRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<School>> getSchools() async {
    try {
      // ApiService retorna diretamente o objeto JSON (não tem .data)
      final response = await apiService.get(ApiConstants.schoolsEndpoint);
      
      print('🔍 DEBUG getSchools response type: ${response.runtimeType}');
      print('🔍 DEBUG getSchools response: $response');
      
      List<dynamic> schoolsData;
      
      // Verifica o formato da resposta
      if (response is Map<String, dynamic>) {
        // Se a resposta é um objeto com chave 'escolas'
        if (response.containsKey('escolas')) {
          schoolsData = response['escolas'] as List;
        } else {
          throw ServerException(
            message: 'Formato de resposta inválido: esperado chave "escolas"',
          );
        }
      } else if (response is List) {
        // Se a resposta já é uma lista direta
        schoolsData = response;
      } else {
        throw ServerException(
          message: 'Formato de resposta inesperado: ${response.runtimeType}',
        );
      }
      
      final schools = schoolsData
          .map((schoolData) => School.fromMap(schoolData as Map<String, dynamic>))
          .toList();
      
      print('✅ Escolas carregadas: ${schools.length}');
      return schools;
      
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      print('❌ Erro em getSchools: $e');
      print('Stack trace: $stackTrace');
      throw ServerException(message: 'Erro ao buscar escolas: $e');
    }
  }

  @override
  Future<School> createSchool({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final response = await apiService.post(
        ApiConstants.schoolsEndpoint,
        body: {
          'nome': nome,  // Backend pode esperar 'nome' ou 'name'
          'email': email,
          'senha': senha, // Backend pode esperar 'senha' ou 'password'
        },
      );
      
      print('🔍 DEBUG createSchool response: $response');
      
      // Verifica diferentes formatos de resposta
      if (response is Map<String, dynamic>) {
        if (response.containsKey('escola')) {
          return School.fromMap(response['escola'] as Map<String, dynamic>);
        } else if (response.containsKey('escolas')) {
          return School.fromMap(response['escolas'] as Map<String, dynamic>);
        } else {
          // Se a resposta é diretamente o objeto da escola
          return School.fromMap(response);
        }
      }
      
      throw ServerException(message: 'Formato de resposta inválido ao criar escola');
      
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      print('❌ Erro em createSchool: $e');
      print('Stack trace: $stackTrace');
      throw ServerException(message: 'Erro ao criar escola: $e');
    }
  }

  @override
  Future<void> deleteSchool(String id) async {
    try {
      await apiService.delete('${ApiConstants.schoolsEndpoint}/$id');
      print('✅ Escola $id deletada com sucesso');
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      print('❌ Erro em deleteSchool: $e');
      print('Stack trace: $stackTrace');
      throw ServerException(message: 'Erro ao deletar escola: $e');
    }
  }
}