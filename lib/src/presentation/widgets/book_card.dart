import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/book.dart';

/// Card para exibir informações de um livro
class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRead;
  final bool showActions;

  const BookCard({
    Key? key,
    required this.book,
    this.onTap,
    this.onDelete,
    this.onRead,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com título e status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ícone do livro
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getBookIcon(),
                      color: theme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Informações do livro
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Por ${book.author}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.grey[300] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status de disponibilidade
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: book.isAvailable
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      book.isAvailable ? 'Disponível' : 'Indisponível',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: book.isAvailable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Descrição (se houver)
              if (book.description != null && book.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  book.description!,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Informações adicionais
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.file_present,
                    size: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${book.fileFormat.toUpperCase()} • ${book.formattedFileSize}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('dd/MM/yyyy').format(book.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              // Ações (se habilitadas)
              if (showActions) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (onRead != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: book.isAvailable ? onRead : null,
                          icon: const Icon(Icons.menu_book, size: 16),
                          label: const Text('Ler'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    
                    if (onRead != null && onDelete != null)
                      const SizedBox(width: 8),
                    
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        tooltip: 'Excluir livro',
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBookIcon() {
    switch (book.fileFormat.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'epub':
        return Icons.book;
      default:
        return Icons.description;
    }
  }
}
