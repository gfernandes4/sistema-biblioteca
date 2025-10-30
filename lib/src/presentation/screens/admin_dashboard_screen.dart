import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/books_provider.dart';
import '../widgets/loading_widget.dart';
import 'admin_master_panel.dart';
import 'admin_school_panel.dart';

/// Tela principal do painel administrativo
/// Detecta o tipo de usuário e exibe o painel apropriado
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega os livros ao abrir o painel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksProvider>().loadBooks(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

 
    // Verifica se o usuário está autenticado
    if (!authProvider.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Painel Administrativo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Acesso negado',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Você precisa estar autenticado como\nAdministrador ou Escola',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    // Mostra loading enquanto o usuário não for totalmente carregado
    if (authProvider.isLoggedIn && authProvider.currentUser == null) {
      return const Scaffold(
        body: LoadingWidget(message: 'Carregando dados do usuário...'),
      );
    }

    // Exibe o painel apropriado baseado no tipo de usuário
    if (authProvider.isAdmin) {
      return const AdminMasterPanel();
    } else if (authProvider.isSchool) {
      return const AdminSchoolPanel();
    }

    // Fallback para tipos de usuário não reconhecidos
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Tipo de usuário não reconhecido',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => authProvider.logout(),
              child: const Text('Fazer logout'),
            ),
          ],
        ),
      ),
    );
  }
}