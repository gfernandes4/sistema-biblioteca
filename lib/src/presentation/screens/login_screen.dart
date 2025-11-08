// [COPIE E COLE ESTE ARQUIVO INTEIRO]
// Substitua todo o conteúdo de login_screen.dart por este:

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/user.dart'; // Import UserType
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

/// Tela de login (Novo Design)
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Oculta a senha por padrão
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A tela de login do novo design não tem AppBar
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          // ConstrainedBox limita a largura do formulário em telas grandes (desktop)
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  // Título "Login" com a fonte Karantina
                  Text(
                    "Login",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 48),
                  
                  // Campo de Registro (novo CustomTextField)
                  CustomTextField(
                    hint: 'Insira seu registro', // Do seu design
                    controller: _usernameController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.person_outline, // Mantido para melhor UX
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Este campo é obrigatório';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Campo de Senha (novo CustomTextField)
                  CustomTextField(
                    hint: 'Insira sua senha', // Do seu design
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outlined, // Mantido para melhor UX
                    suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    onSuffixIconPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Senha é obrigatória';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),
                        
                  // Botão de login "ENTRAR"
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomButton(
                        text: 'ENTRAR', // Do seu design
                        isLoading: authProvider.isLoading,
                        onPressed: () => _handleLogin(context),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Botão "Entrar como Aluno" (Funcionalidade mantida)
                  // Estilizado como 'outlined' para diferenciar
                  CustomButton(
                    text: 'Entrar como Aluno',
                    isOutlined: true,
                    icon: Icons.school,
                    onPressed: () => _handleStudentAccess(context),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Widget de Mensagem de Erro (Funcionalidade mantida)
                  _buildErrorMessage(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Widget para exibir a mensagem de erro (design atualizado)
  Widget _buildErrorMessage() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.errorMessage != null) {
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
                    authProvider.errorMessage!,
                    // Usa a fonte Konkhmer Sleokchher
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red[800],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => authProvider.clearError(),
                  icon: Icon(Icons.close, size: 20, color: Colors.red[700]),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Lógica de login (Admin/Escola) - SEM MUDANÇAS
  Future<void> _handleLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    // TODO: O seu design não tem um switch para Admin/Escola.
    // Por enquanto, ele tentará logar como 'escola' por padrão.
    // Se você precisar do login de Admin, precisaremos adicionar um Switch
    // ou usar um endpoint de login unificado.
    final userType = UserType.school; // Simplificado

    final success = await authProvider.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      userType: userType,
    );

    if (success && mounted) {
      final loggedInUserType = authProvider.currentUserType;
      if (loggedInUserType == 'admin' || loggedInUserType == 'escola') {
        Navigator.of(context).pushReplacementNamed('/admin');
      } else {
        // Se o login for de outro tipo (não admin/escola), vai para home
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  /// Lógica de acesso do Aluno - SEM MUDANÇAS
  void _handleStudentAccess(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }
}