import 'package:logger/logger.dart';

import 'api_service.dart';
// import 'file_service.dart';
import 'database_service.dart';
import 'storage_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/books_remote_datasource.dart';
import '../../data/datasources/books_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/books_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_books_usecase.dart';
import '../../domain/usecases/search_books_usecase.dart';
import '../../domain/usecases/upload_book_usecase.dart';
import '../../domain/usecases/delete_book_usecase.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/books_provider.dart';
import '../../presentation/providers/theme_provider.dart';

/// Service Locator para injeção de dependências
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Singleton para garantir uma única instância
  static ServiceLocator get instance => _instance;

  // Serviços core
  late final Logger _logger;
  late final ApiService _apiService;
  late final DatabaseService _databaseService;
  late final StorageService _storageService;
  

  // Data sources
  late final AuthRemoteDataSource _authRemoteDataSource;
  late final BooksRemoteDataSource _booksRemoteDataSource;
  late final BooksLocalDataSource _booksLocalDataSource;

  // Repositories
  late final AuthRepository _authRepository;
  late final BooksRepository _booksRepository;

  // Use cases
  late final LoginUseCase _loginUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final GetBooksUseCase _getBooksUseCase;
  late final SearchBooksUseCase _searchBooksUseCase;
  late final UploadBookUseCase _uploadBookUseCase;
  late final DeleteBookUseCase _deleteBookUseCase;

  bool _isInitialized = false;

  /// Inicializa todas as dependências
  Future<void> init() async {
    if (_isInitialized) return;

    // Serviços core
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: false,
      ),
    );

    _storageService = StorageService();
    await _storageService.init();

    _apiService = ApiService(logger: _logger);
    _databaseService = DatabaseService();

    // Recuperar token salvo
    final savedToken = _storageService.getAuthToken();
    if (savedToken != null) {
      _apiService.setAuthToken(savedToken);
    }

    // Data sources
    _authRemoteDataSource = AuthRemoteDataSourceImpl(apiService: _apiService);
    _booksRemoteDataSource = BooksRemoteDataSourceImpl(apiService: _apiService);
    _booksLocalDataSource = BooksLocalDataSourceImpl(databaseService: _databaseService);

    // Repositories
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource,
      storageService: _storageService,
    );

    _booksRepository = BooksRepositoryImpl(
      remoteDataSource: _booksRemoteDataSource,
      localDataSource: _booksLocalDataSource,
    );

    // Use cases
    _loginUseCase = LoginUseCase(authRepository: _authRepository);
    _logoutUseCase = LogoutUseCase(authRepository: _authRepository);
    _getBooksUseCase = GetBooksUseCase(booksRepository: _booksRepository);
    _searchBooksUseCase = SearchBooksUseCase(booksRepository: _booksRepository);
    _uploadBookUseCase = UploadBookUseCase(booksRepository: _booksRepository);
    _deleteBookUseCase = DeleteBookUseCase(booksRepository: _booksRepository);

    _isInitialized = true;
    _logger.i('ServiceLocator inicializado com sucesso');
  }

  // Getters para acessar as dependências

  Logger get logger => _logger;
  ApiService get apiService => _apiService;
  DatabaseService get databaseService => _databaseService;
  StorageService get storageService => _storageService;
  // FileService get fileService => _fileService;

  AuthRepository get authRepository => _authRepository;
  BooksRepository get booksRepository => _booksRepository;

  LoginUseCase get loginUseCase => _loginUseCase;
  LogoutUseCase get logoutUseCase => _logoutUseCase;
  GetBooksUseCase get getBooksUseCase => _getBooksUseCase;
  SearchBooksUseCase get searchBooksUseCase => _searchBooksUseCase;
  UploadBookUseCase get uploadBookUseCase => _uploadBookUseCase;
  DeleteBookUseCase get deleteBookUseCase => _deleteBookUseCase;

  /// Cria providers para uso com Provider
  AuthProvider createAuthProvider() {
    return AuthProvider(
      loginUseCase: _loginUseCase,
      logoutUseCase: _logoutUseCase,
      authRepository: _authRepository,
    );
  }

  BooksProvider createBooksProvider() {
    return BooksProvider(
      getBooksUseCase: _getBooksUseCase,
      searchBooksUseCase: _searchBooksUseCase,
      uploadBookUseCase: _uploadBookUseCase,
      deleteBookUseCase: _deleteBookUseCase,
      authRepository: _authRepository,
    );
  }

  ThemeProvider createThemeProvider() {
    return ThemeProvider(storageService: _storageService);
  }

  /// Limpa recursos
  Future<void> dispose() async {
    if (!_isInitialized) return;

    await _databaseService.close();
    _apiService.dispose();
    _isInitialized = false;
    _logger.i('ServiceLocator finalizado');
  }
}
