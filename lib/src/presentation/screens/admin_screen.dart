
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/books_provider.dart';
import '../../domain/entities/book.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BooksProvider>(context, listen: false).loadBooks(forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final booksProvider = context.read<BooksProvider>();
    if (query.isEmpty) {
      booksProvider.clearSearch();
    } else {
      booksProvider.searchBooks(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Administração'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por título...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: Consumer<BooksProvider>(
              builder: (context, booksProvider, child) {
                final bool isSearching = _searchController.text.isNotEmpty;
                final state = isSearching ? booksProvider.searchState : booksProvider.state;
                final books = isSearching ? booksProvider.searchResults : booksProvider.books;
                final errorMessage = isSearching ? booksProvider.searchErrorMessage : booksProvider.errorMessage;

                switch (state) {
                  case BooksState.loading:
                    return const Center(child: CircularProgressIndicator());
                  case BooksState.error:
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Erro: ${errorMessage ?? "Ocorreu um erro"}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => isSearching
                                ? booksProvider.searchBooks(_searchController.text)
                                : booksProvider.loadBooks(forceRefresh: true),
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    );
                  case BooksState.loaded:
                    if (books.isEmpty) {
                      return Center(
                        child: Text(isSearching ? 'Nenhum resultado encontrado.' : 'Nenhum livro cadastrado.'),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => booksProvider.loadBooks(forceRefresh: true),
                      child: ListView.builder(
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return _BookListItem(book: book);
                        },
                      ),
                    );
                  default:
                    return const Center(child: Text('Digite para buscar ou atualize a lista.'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/upload-book');
        },
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Livro',
      ),
    );
  }
}

class _BookListItem extends StatelessWidget {
  final Book book;

  const _BookListItem({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(book.author),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.grey),
              onPressed: () {
                Navigator.of(context).pushNamed('/book-reader', arguments: book.id);
              },
              tooltip: 'Ler',
            ),
            IconButton(
              icon: const Icon(Icons.download, color: Colors.blue),
              onPressed: () {
                // TODO: Implementar download
              },
              tooltip: 'Baixar',
            ),
            if (_canDelete(authProvider, book))
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context, book),
                tooltip: 'Remover',
              ),
          ],
        ),
      ),
    );
  }

  bool _canDelete(AuthProvider authProvider, Book book) {
    if (authProvider.isAdmin) {
      return true;
    }
    if (authProvider.isSchool) {
      return true; // Deixa o backend decidir
    }
    return false;
  }

  void _confirmDelete(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Remoção'),
          content: Text('Você tem certeza que deseja remover o livro "${book.title}"? Esta ação não pode ser desfeita.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Remover', style: TextStyle(color: Colors.red)),
              onPressed: () {
                final booksProvider = context.read<BooksProvider>();
                booksProvider.deleteBook(book.id).then((success) {
                  Navigator.of(dialogContext).pop();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('"${book.title}" foi removido.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Falha ao remover o livro: ${booksProvider.errorMessage}')),
                    );
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }
}
