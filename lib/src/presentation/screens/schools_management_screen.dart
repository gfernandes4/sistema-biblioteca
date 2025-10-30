import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/school.dart';
import '../providers/school_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';

/// Tela de gerenciamento de escolas (apenas para Admin Master)
class SchoolsManagementScreen extends StatefulWidget {
  const SchoolsManagementScreen({Key? key}) : super(key: key);

  @override
  State<SchoolsManagementScreen> createState() => _SchoolsManagementScreenState();
}

class _SchoolsManagementScreenState extends State<SchoolsManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SchoolProvider>().loadSchools();
    });
  }

  @override
  Widget build(BuildContext context) {
    final schoolProvider = context.watch<SchoolProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Escolas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => schoolProvider.loadSchools(forceRefresh: true),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _buildBody(context, schoolProvider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSchoolDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Escola'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SchoolProvider provider) {
    if (provider.state == SchoolsState.loading) {
      return const LoadingWidget(message: 'Carregando escolas...');
    }

    if (provider.state == SchoolsState.error) {
      return ErrorDisplayWidget(
        message: provider.errorMessage ?? 'Erro ao carregar escolas',
        onRetry: () => provider.loadSchools(forceRefresh: true),
      );
    }

    if (provider.schools.isEmpty) {
      return EmptyStateWidget(
        title: 'Nenhuma escola cadastrada',
        message: 'Comece adicionando a primeira escola',
        icon: Icons.school_outlined,
        actionText: 'Adicionar Escola',
        onAction: () => _showAddSchoolDialog(context),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadSchools(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.schools.length,
        itemBuilder: (context, index) {
          final school = provider.schools[index];
          return _buildSchoolCard(context, school, provider);
        },
      ),
    );
  }

  Widget _buildSchoolCard(
    BuildContext context,
    School school,
    SchoolProvider provider,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.school,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school.nome,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            size: 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              school.email,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditSchoolDialog(context, school);
                    } else if (value == 'delete') {
                      _confirmDelete(context, provider, school);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 12),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Excluir', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (school.createdAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Criado em: ${_formatDate(school.createdAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddSchoolDialog(BuildContext context) {
    final nomeController = TextEditingController();
    final emailController = TextEditingController();
    final senhaController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Adicionar Escola'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    label: 'Nome da Escola',
                    controller: nomeController,
                    prefixIcon: Icons.school,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nome é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Email',
                    controller: emailController,
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email é obrigatório';
                      }
                      if (!value.contains('@')) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Senha',
                    controller: senhaController,
                    prefixIcon: Icons.lock,
                    obscureText: obscurePassword,
                    suffixIcon: obscurePassword ? Icons.visibility : Icons.visibility_off,
                    onSuffixIconPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Senha é obrigatória';
                      }
                      if (value.length < 6) {
                        return 'Senha deve ter no mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            Consumer<SchoolProvider>(
              builder: (context, provider, _) {
                return ElevatedButton(
                  onPressed: provider.isOperating
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            final success = await provider.createSchool(
                              nome: nomeController.text,
                              email: emailController.text,
                              senha: senhaController.text,
                            );

                            if (context.mounted) {
                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Escola criada com sucesso'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      provider.operationError ?? 'Erro ao criar escola',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  child: provider.isOperating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Adicionar'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSchoolDialog(BuildContext context, School school) {
    final nomeController = TextEditingController(text: school.nome);
    final emailController = TextEditingController(text: school.email);
    final senhaController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Escola'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    label: 'Nome da Escola',
                    controller: nomeController,
                    prefixIcon: Icons.school,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nome é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Email',
                    controller: emailController,
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email é obrigatório';
                      }
                      if (!value.contains('@')) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Nova Senha (deixe vazio para manter)',
                    controller: senhaController,
                    prefixIcon: Icons.lock,
                    obscureText: obscurePassword,
                    suffixIcon: obscurePassword ? Icons.visibility : Icons.visibility_off,
                    onSuffixIconPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    validator: (value) {
                      if (value != null && value.isNotEmpty && value.length < 6) {
                        return 'Senha deve ter no mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            Consumer<SchoolProvider>(
              builder: (context, provider, _) {
                return ElevatedButton(
                  onPressed: provider.isOperating
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            final success = await provider.updateSchool(
                              id: school.id,
                              nome: nomeController.text,
                              email: emailController.text,
                              senha: senhaController.text.isEmpty
                                  ? null
                                  : senhaController.text,
                            );

                            if (context.mounted) {
                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Escola atualizada com sucesso'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      provider.operationError ?? 'Erro ao atualizar escola',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  child: provider.isOperating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, SchoolProvider provider, School school) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Tem certeza que deseja excluir a escola "${school.nome}"?\n\n'
          'Esta ação não pode ser desfeita e a escola não poderá mais acessar o sistema.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteSchool(school.id);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Escola excluída com sucesso'
                          : provider.operationError ?? 'Erro ao excluir escola',
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}