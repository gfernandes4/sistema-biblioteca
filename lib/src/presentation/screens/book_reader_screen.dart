import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../core/constants/api_constants.dart';
import '../../domain/entities/book.dart';

import '../providers/books_provider.dart';
import '../widgets/error_widget.dart';

/// Tela para leitura de livros (PDF/EPUB)
class BookReaderScreen extends StatefulWidget {
  final String bookId;

  const BookReaderScreen({
    Key? key,
    required this.bookId,
  }) : super(key: key);

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  bool _isFullScreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen ? null : _buildAppBar(),
      body: Consumer<BooksProvider>(
        builder: (context, booksProvider, child) {
          final book = booksProvider.getBookById(widget.bookId);

          if (book == null) {
            return const ErrorDisplayWidget(
              message: 'Livro não encontrado',
              icon: Icons.book_outlined,
            );
          }

          if (!book.isAvailable) {
            return const ErrorDisplayWidget(
              message: 'Este livro não está disponível para leitura',
              icon: Icons.block,
            );
          }

          // Para o MVP, vamos assumir que todos os livros são PDFs
          // Em uma implementação completa, você verificaria book.fileFormat
          return _buildPdfViewer(book, book.title);
        },
      ),
      floatingActionButton: _isFullScreen ? _buildFullScreenFAB() : null,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Consumer<BooksProvider>(
        builder: (context, booksProvider, child) {
          final book = booksProvider.getBookById(widget.bookId);
          return Text(
            book?.title ?? 'Leitor',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: _toggleFullScreen,
          icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
          tooltip: _isFullScreen ? 'Sair da tela cheia' : 'Tela cheia',
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'zoom_in':
                _pdfController.zoomLevel = _pdfController.zoomLevel * 1.25;
                break;
              case 'zoom_out':
                _pdfController.zoomLevel = _pdfController.zoomLevel * 0.8;
                break;
              case 'fit_width':
                // Implementar ajuste à largura
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'zoom_in',
              child: Row(
                children: [
                  Icon(Icons.zoom_in),
                  SizedBox(width: 8),
                  Text('Aumentar zoom'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'zoom_out',
              child: Row(
                children: [
                  Icon(Icons.zoom_out),
                  SizedBox(width: 8),
                  Text('Diminuir zoom'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'fit_width',
              child: Row(
                children: [
                  Icon(Icons.fit_screen),
                  SizedBox(width: 8),
                  Text('Ajustar à largura'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPdfViewer(Book book, String title) {
    return GestureDetector(
      onTap: _isFullScreen ? _toggleFullScreen : null,
      child: Container(
        color: Colors.grey[100],
        child: SfPdfViewer.network(
          // Construir URL de download do backend: {baseUrl}/livros/{id}/arquivo
          '${ApiConstants.baseUrl}${ApiConstants.booksEndpoint}/${book.id}/arquivo',
          controller: _pdfController,
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            // Em caso de erro ao carregar o PDF
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _showErrorDialog('Erro ao carregar o arquivo PDF: ${details.error}');
              }
            });
          },
          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
            // Documento carregado com sucesso
            debugPrint('PDF carregado: ${details.document.pages.count} páginas');
          },
        ),
      ),
    );
  }

  Widget _buildFullScreenFAB() {
    return FloatingActionButton(
      onPressed: _toggleFullScreen,
      child: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
      tooltip: _isFullScreen ? 'Sair da tela cheia' : 'Tela cheia',
    );
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Voltar para a tela anterior
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }
}
