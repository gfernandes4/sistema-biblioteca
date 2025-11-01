// [COPIE E COLE ESTE ARQUIVO INTEIRO]
// Substitua todo o conteúdo de custom_button.dart por este:

import 'package:flutter/material.dart';

/// Botão customizado reutilizável (Novo Design)
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double? height;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Os estilos (cor, fonte, tamanho) agora vêm do app_themes.dart
    // (elevatedButtonTheme e outlinedButtonTheme)

    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height ?? 52, // Altura padrão do novo tema
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildChild(context, isOutlined: true),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height ?? 52, // Altura padrão do novo tema
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: _buildChild(context, isOutlined: false),
      ),
    );
  }

  Widget _buildChild(BuildContext context, {required bool isOutlined}) {
    if (isLoading) {
      // Define a cor do indicador de loading
      final color = isOutlined 
          ? Theme.of(context).primaryColor 
          : Colors.white;
          
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    
    // Força o texto para MAIÚSCULAS, como no design
    final buttonText = Text(text.toUpperCase());

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center, // Centraliza o ícone e texto
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          buttonText,
        ],
      );
    }

    return buttonText;
  }
}