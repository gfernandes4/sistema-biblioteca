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

/// Painel da Escola
/// Pode adicionar e remover seus próprios livros
class AdminSchoolPanel extends StatefulWidget {
  const AdminSchoolPanel({Key? key}) : super(key: key);

  @override
  State<AdminSchoolPanel> createState() => _AdminSchoolPanelState();
}

class _AdminSchoolPanelState extends State<AdminSchoolPanel> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  bool _showSearch = false;
  bool _showOnlyMyBooks = false;

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
        title: const Text('Painel da Escola'),
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
          // Header com informações da escola
          _buildSchoolHeader(context, authProvider),

          // Estatísticas
          _buildStatisticsCards(context, booksProvider, authProvider),

          // Barra de busca e filtros
          if (_showSearch) _buildSearchBar(context, booksProvider),

          // Filtro "Meus livros"
          _buildMyBooksFilter(context),

          // Lista de livros
          Expanded(
            child: _buildBooksList(context, booksProvider, authProvider),
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

  Widget _buildSchoolHeader(BuildContext context, AuthProvider authProvider) {
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
            backgroundColor: Colors.orange,
            child: const Icon(Icons.school, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Escola',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? 'escola@biblioteca.com',
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
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'ESCOLA',
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

  Widget _buildStatisticsCards(
    BuildContext context,
    BooksProvider provider,
    AuthProvider authProvider,
  ) {
    final theme = Theme.of(context);
    final books = provider.books;
    final userId = authProvider.currentUser?.id;

    final myBooks = books.where((b) => b.uploadedBy == userId).length;
    final totalBooks = books.length;
    final availableBooks = books.where((b) => b.isAvailable).length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              'Meus Livros',
              myBooks.toString(),
              Icons.upload_file,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              'Total Biblioteca',
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

  Widget _buildMyBooksFilter(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: CheckboxListTile(
              title: const Text('Mostrar apenas meus livros'),
              value: _showOnlyMyBooks,
              onChanged: (value) {
                setState(() {
                  _showOnlyMyBooks = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList(
    BuildContext context,
    BooksProvider provider,
    AuthProvider authProvider,
  ) {
    if (provider.state == BooksState.loading) {
      return const LoadingWidget(message: 'Carregando livros...');
    }

    if (provider.state == BooksState.error) {
      return ErrorDisplayWidget(
        message: provider.errorMessage ?? 'Erro ao carregar livros',
        onRetry: () => provider.loadBooks(forceRefresh: true),
      );
    }

    final userId = authProvider.currentUser?.id;

    // Determina qual lista usar (busca ou todos os livros)
    var books = provider.hasSearchResults
        ? provider.searchResults
        : provider.books;

    // Filtra apenas livros da escola se necessário
    if (_showOnlyMyBooks && userId != null) {
      books = books.where((b) => b.uploadedBy == userId).toList();
    }

    // Aplica filtro de categoria se selecionado
    final filteredBooks = _selectedCategory != null
        ? books.where((b) => b.category == _selectedCategory).toList()
        : books;

    if (filteredBooks.isEmpty) {
      return EmptyStateWidget(
        title: 'Nenhum livro encontrado',
        message: _showOnlyMyBooks
            ? 'Você ainda não adicionou nenhum livro'
            : provider.hasSearchResults || _selectedCategory != null
                ? 'Tente ajustar seus filtros de busca'
                : 'A biblioteca está vazia',
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
          final isMyBook = book.uploadedBy == userId;

          return BookCard(
            book: book,
            onTap: () => _showBookDetails(context, book, isMyBook),
            // Apenas mostra opção de deletar se for livro da escola
            onDelete: isMyBook
                ? () => _confirmDelete(context, provider, book)
                : null,
            onRead: () => _readBook(context, book),
          );
        },
      ),
    );
  }

  void _showBookDetails(BuildContext context, Book book, bool isMyBook) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(book.title)),
            if (isMyBook)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'MEU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
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
                const Text(
                  'Descrição',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                // Navega para o login e limpa a pilha de navegação
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}