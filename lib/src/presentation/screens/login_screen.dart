import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../../core/constants/app_constants.dart';

/// Tela de login
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // Logo e título
                Icon(
                  Icons.menu_book,
                  size: 80,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  AppConstants.appName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Acesse sua biblioteca digital',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 60),
                
                // Campos de login
                CustomTextField(
                  label: 'E-mail',
                  hint: 'Digite seu e-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'E-mail é obrigatório';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Senha',
                  hint: 'Digite sua senha',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  onSuffixIconPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Senha é obrigatória';
                    }
                    if (value.length < 6) {
                      return 'Senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Botão de login
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: 'Entrar',
                      isLoading: authProvider.isLoading,
                      onPressed: () => _handleLogin(context),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Acesso de aluno (sem login)
                CustomButton(
                  text: 'Entrar como Aluno',
                  isOutlined: true,
                  icon: Icons.school,
                  onPressed: () => _handleStudentAccess(context),
                ),
                
                const SizedBox(height: 24),
                
                // Mensagem de erro
                Consumer<AuthProvider>(
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
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authProvider.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            IconButton(
                              onPressed: () => authProvider.clearError(),
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
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      final userType = authProvider.currentUserType;
      if (userType == 'admin' || userType == 'escola') {
        Navigator.of(context).pushReplacementNamed('/admin');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  void _handleStudentAccess(BuildContext context) {
    // Para acesso de aluno, navegar diretamente para home sem login
    // Limpa a pilha de navegação para evitar o botão "voltar" indesejado
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }
}
