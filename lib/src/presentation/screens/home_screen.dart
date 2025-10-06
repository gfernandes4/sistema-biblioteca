import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/books_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/book_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_state_widget.dart';

/// Tela principal do aplicativo
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksProvider>().loadBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isSearching ? _buildSearchResults() : _buildBooksList(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Biblioteca Digital'),
      actions: [
        // Botão de tema
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              onPressed: themeProvider.toggleTheme,
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              tooltip: 'Alternar tema',
            );
          },
        ),
        
        // Menu do usuário
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoggedIn) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      // Implementar tela de perfil
                      break;
                    case 'logout':
                      _handleLogout();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: const [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('Perfil'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: const [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Sair'),
                      ],
                    ),
                  ),
                ],
                child: const Icon(Icons.account_circle),
              );
            } else {
              return IconButton(
                onPressed: () => Navigator.of(context).pushNamed('/login'),
                icon: const Icon(Icons.login),
                tooltip: 'Fazer login',
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar livros...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.trim().isEmpty) {
                  _clearSearch();
                } else {
                  _performSearch(value.trim());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList() {
    return Consumer<BooksProvider>(
      builder: (context, booksProvider, child) {
        switch (booksProvider.state) {
          case BooksState.loading:
            return const LoadingWidget(message: 'Carregando livros...');
          
          case BooksState.error:
            return ErrorDisplayWidget(
              message: booksProvider.errorMessage ?? 'Erro ao carregar livros',
              onRetry: () => booksProvider.loadBooks(forceRefresh: true),
            );
          
          case BooksState.loaded:
            if (booksProvider.books.isEmpty) {
              return EmptyStateWidget(
                title: 'Nenhum livro encontrado',
                message: 'A biblioteca ainda não possui livros cadastrados.',
                icon: Icons.menu_book,
                actionText: _canManageBooks ? 'Adicionar livro' : null,
                onAction: _canManageBooks ? () => _navigateToUpload() : null,
              );
            }
            
            return RefreshIndicator(
              onRefresh: () => booksProvider.loadBooks(forceRefresh: true),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: booksProvider.books.length,
                itemBuilder: (context, index) {
                  final book = booksProvider.books[index];
                  return BookCard(
                    book: book,
                    onTap: () => _openBook(book.id),
                    onRead: () => _readBook(book.id),
                    onDelete: _canManageBooks ? () => _deleteBook(book.id) : null,
                    showActions: true,
                  );
                },
              ),
            );
          
          default:
            return const Center(child: Text('Inicializando...'));
        }
      },
    );
  }

  Widget _buildSearchResults() {
    return Consumer<BooksProvider>(
      builder: (context, booksProvider, child) {
        switch (booksProvider.searchState) {
          case BooksState.loading:
            return const LoadingWidget(message: 'Buscando...');
          
          case BooksState.error:
            return ErrorDisplayWidget(
              message: booksProvider.searchErrorMessage ?? 'Erro na busca',
              onRetry: () => _performSearch(_searchController.text.trim()),
            );
          
          case BooksState.loaded:
            if (booksProvider.searchResults.isEmpty) {
              return EmptyStateWidget(
                title: 'Nenhum resultado',
                message: 'Não encontramos livros para "${booksProvider.currentSearchQuery}".',
                icon: Icons.search_off,
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: booksProvider.searchResults.length,
              itemBuilder: (context, index) {
                final book = booksProvider.searchResults[index];
                return BookCard(
                  book: book,
                  onTap: () => _openBook(book.id),
                  onRead: () => _readBook(book.id),
                  onDelete: _canManageBooks ? () => _deleteBook(book.id) : null,
                  showActions: true,
                );
              },
            );
          
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget? _buildFloatingActionButton() {
    if (!_canManageBooks) return null;

    return FloatingActionButton.extended(
      onPressed: _navigateToUpload,
      icon: const Icon(Icons.add),
      label: const Text('Adicionar Livro'),
    );
  }

  bool get _canManageBooks {
    final authProvider = context.read<AuthProvider>();
    return authProvider.canManageBooks;
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = true;
    });
    context.read<BooksProvider>().searchBooks(query);
  }

  void _clearSearch() {
    setState(() {
      _isSearching = false;
    });
    _searchController.clear();
    context.read<BooksProvider>().clearSearch();
  }

  void _openBook(String bookId) {
    Navigator.of(context).pushNamed('/book-details', arguments: bookId);
  }

  void _readBook(String bookId) {
    Navigator.of(context).pushNamed('/book-reader', arguments: bookId);
  }

  Future<void> _deleteBook(String bookId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir este livro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<BooksProvider>().deleteBook(bookId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Livro excluído com sucesso')),
        );
      }
    }
  }

  void _navigateToUpload() {
    Navigator.of(context).pushNamed('/upload-book');
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar saída'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
}
