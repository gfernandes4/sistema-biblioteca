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
              CustomTextField(
                label: 'Título *',
                hint: 'Digite o título do livro',
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
              CustomTextField(
                label: 'Autor *',
                hint: 'Digite o nome do autor',
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
              CustomTextField(
                label: 'Descrição',
                hint: 'Digite uma descrição do livro (opcional)',
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
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              booksProvider.uploadErrorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            onPressed: () => booksProvider.clearUploadError(),
                            icon: const Icon(Icons.close, size: 18),
                            color: Colors.red,
                          ),
                        ],
                      ),
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
        Text(
          'Arquivo do Livro *',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedFile != null
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tamanho: ${_getFileSizeString(_selectedFile!.lengthSync())}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ] else ...[
                Text(
                  'Selecione um arquivo PDF ou EPUB',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tamanho máximo: ${AppConstants.maxFileSize ~/ (1024 * 1024)}MB',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
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
        Text(
          'Categoria *',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
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
