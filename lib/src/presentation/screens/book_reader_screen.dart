import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../domain/entities/book.dart';
import '../providers/books_provider.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';

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
  Future<String?>? _downloadFuture;

  @override
  void initState() {
    super.initState();
    // Iniciar o download quando a tela for construída
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final book = context.read<BooksProvider>().getBookById(widget.bookId);
      if (book != null && book.isAvailable) {
        setState(() {
          _downloadFuture = context.read<BooksProvider>().downloadBook(book);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final book = context.watch<BooksProvider>().getBookById(widget.bookId);

    return Scaffold(
      appBar: _isFullScreen ? null : _buildAppBar(book),
      body: _buildBody(book),
      floatingActionButton: _isFullScreen ? _buildFullScreenFAB() : null,
    );
  }

  AppBar _buildAppBar(Book? book) {
    return AppBar(
      title: Text(
        book?.title ?? 'Leitor',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          onPressed: _toggleFullScreen,
          icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
          tooltip: _isFullScreen ? 'Sair da tela cheia' : 'Tela cheia',
        ),
        // Outras ações como zoom podem ser adicionadas aqui se necessário
      ],
    );
  }

  Widget _buildBody(Book? book) {
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

    return FutureBuilder<String?>(
      future: _downloadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: 'Baixando livro...');
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return ErrorDisplayWidget(
            message: 'Falha ao baixar o livro. Tente novamente.\nErro: ${snapshot.error}',
            icon: Icons.cloud_off,
          );
        }

        final localPath = snapshot.data!;
        return _buildPdfViewer(localPath);
      },
    );
  }

  Widget _buildPdfViewer(String localPath) {
    return GestureDetector(
      onTap: _isFullScreen ? _toggleFullScreen : null,
      child: Container(
        color: Colors.grey[100],
        child: SfPdfViewer.file(
          File(localPath),
          controller: _pdfController,
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _showErrorDialog('Erro ao carregar o arquivo PDF: ${details.error}');
              }
            });
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
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(); // Voltar para a tela anterior
              }
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
