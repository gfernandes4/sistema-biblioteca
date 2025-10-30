import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/book.dart';
import '../providers/auth_provider.dart';
import '../providers/books_provider.dart';
import '../widgets/book_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import 'upload_book_screen.dart';

/// Painel do Administrador Master
/// Acesso total ao sistema, pode gerenciar todos os livros
class AdminMasterPanel extends StatefulWidget {
  const AdminMasterPanel({Key? key}) : super(key: key);

  @override
  State<AdminMasterPanel> createState() => _AdminMasterPanelState();
}

class _AdminMasterPanelState extends State<AdminMasterPanel> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final booksProvider = context.watch<BooksProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
        actions: [
          // Botão de busca
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  booksProvider.clearSearch();
                  _selectedCategory = null;
                }
              });
            },
          ),
          // Botão de logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context, authProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header com informações do usuário
          _buildUserHeader(context, authProvider),

          // Estatísticas
          _buildStatisticsCards(context, booksProvider),

          // Barra de busca e filtros
          if (_showSearch) _buildSearchBar(context, booksProvider),

          // Lista de livros
          Expanded(
            child: _buildBooksList(context, booksProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToUpload(context),
        icon: const Icon(Icons.upload_file),
        label: const Text('Adicionar Livro'),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, AuthProvider authProvider) {
    final theme = Theme.of(context);
    final user = authProvider.currentUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.primaryColor,
            child: const Icon(Icons.admin_panel_settings, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Administrador Master',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? 'admin@biblioteca.com',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'ADMIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(BuildContext context, BooksProvider provider) {
    final theme = Theme.of(context);
    final books = provider.books;

    final totalBooks = books.length;
    final availableBooks = books.where((b) => b.isAvailable).length;
    final categories = books.map((b) => b.category).toSet().length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              'Total de Livros',
              totalBooks.toString(),
              Icons.library_books,
              theme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              'Disponíveis',
              availableBooks.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              'Categorias',
              categories.toString(),
              Icons.category,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, BooksProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por título, autor...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.clearSearch();
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      provider.searchBooks(value);
                    } else {
                      provider.clearSearch();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.filter_list,
                  color: _selectedCategory != null
                      ? Theme.of(context).primaryColor
                      : null,
                ),
                tooltip: 'Filtrar por categoria',
                onSelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: null,
                    child: Text('Todas as categorias'),
                  ),
                  ...BookCategories.all.map(
                    (category) => PopupMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_selectedCategory != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Chip(
                    label: Text(_selectedCategory!),
                    onDeleted: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBooksList(BuildContext context, BooksProvider provider) {
    if (provider.state == BooksState.loading) {
      return const LoadingWidget(message: 'Carregando livros...');
    }

    if (provider.state == BooksState.error) {
      return ErrorDisplayWidget(
        message: provider.errorMessage ?? 'Erro ao carregar livros',
        onRetry: () => provider.loadBooks(forceRefresh: true),
      );
    }

    // Determina qual lista usar (busca ou todos os livros)
    final books = provider.hasSearchResults
        ? provider.searchResults
        : provider.books;

    // Aplica filtro de categoria se selecionado
    final filteredBooks = _selectedCategory != null
        ? books.where((b) => b.category == _selectedCategory).toList()
        : books;

    if (filteredBooks.isEmpty) {
      return EmptyStateWidget(
        title: 'Nenhum livro encontrado',
        message: provider.hasSearchResults || _selectedCategory != null
            ? 'Tente ajustar seus filtros de busca'
            : 'Comece adicionando o primeiro livro',
        icon: Icons.library_books_outlined,
        actionText: 'Adicionar Livro',
        onAction: () => _navigateToUpload(context),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadBooks(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredBooks.length,
        itemBuilder: (context, index) {
          final book = filteredBooks[index];
          return BookCard(
            book: book,
            onTap: () => _showBookDetails(context, book),
            onDelete: () => _confirmDelete(context, provider, book),
            onRead: () => _readBook(context, book),
          );
        },
      ),
    );
  }

  void _showBookDetails(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Autor', book.author),
              _buildDetailRow('Categoria', book.category),
              _buildDetailRow('Formato', book.fileFormat.toUpperCase()),
              _buildDetailRow('Tamanho', book.formattedFileSize),
              if (book.description != null) ...[
                const Divider(height: 24),
                Text(
                  'Descrição',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(book.description!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, BooksProvider provider, Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o livro "${book.title}"?\n\nEsta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteBook(book.id);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Livro excluído com sucesso'
                          : 'Erro ao excluir livro',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _readBook(BuildContext context, Book book) {
    // TODO: Implementar navegação para tela de leitura
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Função de leitura será implementada'),
      ),
    );
  }

  void _navigateToUpload(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UploadBookScreen(),
      ),
    );
  }

  void _handleLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar logout'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pop(context); // Fecha o diálogo
                Navigator.pop(context); // Volta para tela anterior
              }
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}