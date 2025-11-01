// [COPIE E COLE ESTE ARQUIVO INTEIRO]
// Substitua todo o conteúdo de custom_text_field.dart por este:

import 'package:flutter/material.dart';

/// Campo de texto customizado reutilizável (Novo Design)
class CustomTextField extends StatelessWidget {
  final String hint; // 'label' foi substituída por 'hint'
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final int maxLines;
  final bool enabled;
  final String? errorText;
  final Function(String)? onChanged;

  const CustomTextField({
    Key? key,
    required this.hint, // Alterado de 'label' para 'hint'
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.maxLines = 1,
    this.enabled = true,
    this.errorText,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Removemos o "Column" e o "Text" que existiam antes
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
      // O estilo agora vem do inputDecorationTheme no app_themes.dart
      decoration: InputDecoration(
        hintText: hint, // 'hint' é usado diretamente
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon),
                onPressed: onSuffixIconPressed,
              )
            : null,
        errorText: errorText,
      ),
    );
  }
}