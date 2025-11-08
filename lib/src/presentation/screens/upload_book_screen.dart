// [COPIE E COLE ESTE ARQUIVO INTEIRO]
// Substitua todo o conteúdo de upload_book_screen.dart por este:

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/books_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../../domain/entities/book.dart';
import '../../core/constants/app_constants.dart';

/// Tela para upload/cadastro de livros
class UploadBookScreen extends StatefulWidget {
  const UploadBookScreen({Key? key}) : super(key: key);

  @override
  State<UploadBookScreen> createState() => _UploadBookScreenState();
}

class _UploadBookScreenState extends State<UploadBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = BookCategories.all.first;
  File? _selectedFile;
  String? _fileName;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Estilo de texto para os rótulos, usando a nova fonte do tema
  TextStyle? _getLabelStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontSize: 18, // Um pouco maior para rótulos de formulário
      color: Theme.of(context).primaryColor, // Cor azul
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Livro'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seleção de arquivo
              _buildFileSelection(),
              const SizedBox(height: 24),
              
              // Título
              // [CORREÇÃO: 'label' alterado para 'hint']
              CustomTextField(
                hint: 'Título *',
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Título é obrigatório';
                  }
                  if (value.trim().length < 2) {
                    return 'Título deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Autor
              // [CORREÇÃO: 'label' alterado para 'hint']
              CustomTextField(
                hint: 'Autor *',
                controller: _authorController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Autor é obrigatório';
                  }
                  if (value.trim().length < 2) {
                    return 'Nome do autor deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Categoria
              _buildCategoryDropdown(),
              
              const SizedBox(height: 16),
              
              // Descrição
              // [CORREÇÃO: 'label' alterado para 'hint']
              CustomTextField(
                hint: 'Descrição (opcional)',
                controller: _descriptionController,
                maxLines: 3,
              ),
              
              const SizedBox(height: 32),
              
              // Botão de upload
              Consumer<BooksProvider>(
                builder: (context, booksProvider, child) {
                  return CustomButton(
                    text: 'Adicionar Livro',
                    isLoading: booksProvider.isUploading,
                    onPressed: _selectedFile != null ? _handleUpload : null,
                    icon: Icons.cloud_upload,
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Mensagem de erro
              Consumer<BooksProvider>(
                builder: (context, booksProvider, child) {
                  if (booksProvider.uploadErrorMessage != null) {
                    return _buildErrorMessage(booksProvider.uploadErrorMessage!, 
                      () => booksProvider.clearUploadError()
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rótulo de texto com a nova fonte
        Text(
          'Arquivo do Livro *',
          style: _getLabelStyle(context),
        ),
        const SizedBox(height: 8),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            border: Border.all(
              color: _selectedFile != null
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade400,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                _selectedFile != null ? Icons.check_circle : Icons.cloud_upload,
                size: 48,
                color: _selectedFile != null
                    ? Colors.green
                    : Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              
              if (_selectedFile != null) ...[
                Text(
                  _fileName ?? 'Arquivo selecionado',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tamanho: ${_getFileSizeString(_selectedFile!.lengthSync())}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ] else ...[
                Text(
                  'Selecione um arquivo PDF ou EPUB',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tamanho máximo: ${AppConstants.maxFileSize ~/ (1024 * 1024)}MB',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              
              const SizedBox(height: 16),
              
              CustomButton(
                text: _selectedFile != null ? 'Alterar Arquivo' : 'Selecionar Arquivo',
                isOutlined: true,
                onPressed: _pickFile,
                icon: Icons.folder_open,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rótulo de texto com a nova fonte
        Text(
          'Categoria *',
          style: _getLabelStyle(context),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          // Decoração usa o tema (fundo cinza)
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: BookCategories.all.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Categoria é obrigatória';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Widget de erro (usa o mesmo estilo do login)
  Widget _buildErrorMessage(String message, VoidCallback onClear) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[700],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red[800],
              ),
            ),
          ),
          IconButton(
            onPressed: onClear,
            icon: Icon(Icons.close, size: 20, color: Colors.red[700]),
          ),
        ],
      ),
    );
  }


  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.supportedBookFormats,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);
        final fileSize = file.lengthSync();

        if (fileSize > AppConstants.maxFileSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Arquivo muito grande. Tamanho máximo: ${AppConstants.maxFileSize ~/ (1024 * 1024)}MB',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedFile = file;
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar arquivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate() || _selectedFile == null) {
      return;
    }

    final booksProvider = context.read<BooksProvider>();
    final success = await booksProvider.uploadBook(
      file: _selectedFile!,
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      category: _selectedCategory,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Livro adicionado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  String _getFileSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}