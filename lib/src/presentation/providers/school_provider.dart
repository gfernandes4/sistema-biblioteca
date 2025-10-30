import 'package:flutter/foundation.dart';

import '../../domain/entities/school.dart';
import '../../domain/usecases/school_usecases.dart';
import '../../core/errors/failures.dart';

/// Estados possíveis da lista de escolas
enum SchoolsState {
  initial,
  loading,
  loaded,
  error,
}

/// Provider para gerenciar estado das escolas
class SchoolProvider extends ChangeNotifier {
  final GetSchoolsUseCase getSchoolsUseCase;
  final GetSchoolByIdUseCase getSchoolByIdUseCase;
  final CreateSchoolUseCase createSchoolUseCase;
  final UpdateSchoolUseCase updateSchoolUseCase;
  final DeleteSchoolUseCase deleteSchoolUseCase;

  SchoolProvider({
    required this.getSchoolsUseCase,
    required this.getSchoolByIdUseCase,
    required this.createSchoolUseCase,
    required this.updateSchoolUseCase,
    required this.deleteSchoolUseCase,
  });

  // Estado principal
  SchoolsState _state = SchoolsState.initial;
  List<School> _schools = [];
  String? _errorMessage;

  // Estado de operações
  bool _isOperating = false; // Para criar/atualizar/deletar
  String? _operationError;

  // Getters
  SchoolsState get state => _state;
  List<School> get schools => _schools;
  String? get errorMessage => _errorMessage;
  bool get isOperating => _isOperating;
  String? get operationError => _operationError;

  /// Carrega todas as escolas
  Future<void> loadSchools({bool forceRefresh = false}) async {
    print('🔄 SchoolProvider: Iniciando loadSchools...');
    _setState(SchoolsState.loading);
    _clearError();

    try {
      print('📡 SchoolProvider: Chamando getSchoolsUseCase...');
      final loadedSchools = await getSchoolsUseCase();
      print('✅ SchoolProvider: ${loadedSchools.length} escolas carregadas');
      _schools = loadedSchools;
      _setState(SchoolsState.loaded);
    } catch (e, stackTrace) {
      print('❌ SchoolProvider: Erro ao carregar escolas: $e');
      print('Stack trace: $stackTrace');
      _setError(_getErrorMessage(e));
      _setState(SchoolsState.error);
    }
  }

  /// Busca escola por ID
  Future<School?> getSchoolById(String id) async {
    try {
      return await getSchoolByIdUseCase(id: id);
    } catch (e) {
      _setOperationError(_getErrorMessage(e));
      return null;
    }
  }

  /// Cria nova escola
  Future<bool> createSchool({
    required String nome,
    required String email,
    required String senha,
  }) async {
    _setOperating(true);
    _clearOperationError();

    try {
      final newSchool = await createSchoolUseCase(
        nome: nome,
        email: email,
        senha: senha,
      );

      // Adicionar nova escola à lista local
      _schools.insert(0, newSchool);
      
      _setOperating(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setOperationError(_getErrorMessage(e));
      _setOperating(false);
      return false;
    }
  }

  /// Atualiza escola existente
  Future<bool> updateSchool({
    required String id,
    required String nome,
    required String email,
    String? senha,
  }) async {
    _setOperating(true);
    _clearOperationError();

    try {
      final updatedSchool = await updateSchoolUseCase(
        id: id,
        nome: nome,
        email: email,
        senha: senha,
      );

      // Atualizar escola na lista local
      final index = _schools.indexWhere((s) => s.id == id);
      if (index != -1) {
        _schools[index] = updatedSchool;
      }
      
      _setOperating(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setOperationError(_getErrorMessage(e));
      _setOperating(false);
      return false;
    }
  }

  /// Deleta uma escola
  Future<bool> deleteSchool(String id) async {
    _setOperating(true);
    _clearOperationError();

    try {
      await deleteSchoolUseCase(id: id);
      
      // Remover escola da lista local
      _schools.removeWhere((s) => s.id == id);
      
      _setOperating(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setOperationError(_getErrorMessage(e));
      _setOperating(false);
      return false;
    }
  }

  // === Métodos privados para gerenciar estado ===

  void _setState(SchoolsState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setOperating(bool operating) {
    _isOperating = operating;
    notifyListeners();
  }

  void _setOperationError(String error) {
    _operationError = error;
    notifyListeners();
  }

  void _clearOperationError() {
    _operationError = null;
  }

  /// Limpa erros manualmente (para UI)
  void clearError() => _clearError();
  void clearOperationError() => _clearOperationError();

  /// Converte exceção em mensagem amigável
  String _getErrorMessage(dynamic error) {
    if (error is Failure) {
      return error.message;
    }
    if (error is ArgumentError) {
      return error.message ?? 'Erro de validação';
    }
    return 'Erro inesperado: $error';
  }
}