// [COPIE E COLE ESTE ARQUIVO INTEIRO]
// Substitua todo o conteúdo de app_themes.dart por este:

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Define as cores principais do novo design
class AppColors {
  static const Color navyBlue = Color(0xFF253258);
  static const Color lightGrayBackground = Color(0xFFF5F5F5);
  static const Color scaffoldWhite = Color(0xFFFFFFFF);
  static const Color errorRed = Color(0xFFB00020);
  static const Color textGray = Color(0xFF4A4A4A);
  static const Color hintGray = Color(0xFF8A8A8A);
}

/// Temas da aplicação
class AppThemes {
  
  // Define os estilos de fonte que serão usados no app
  static final TextTheme _textTheme = TextTheme(
    // Karantina para títulos grandes
    headlineLarge: GoogleFonts.karantina(
      fontSize: 72,
      fontWeight: FontWeight.bold,
      color: AppColors.navyBlue,
    ),
    // Karantina para títulos médios
    headlineMedium: GoogleFonts.karantina(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      color: AppColors.navyBlue,
    ),
    // Konkhmer Sleokchher para texto de corpo
    bodyLarge: GoogleFonts.konkhmerSleokchher(
      fontSize: 16,
      color: AppColors.textGray,
    ),
    bodyMedium: GoogleFonts.konkhmerSleokchher(
      fontSize: 14,
      color: AppColors.hintGray,
    ),
    // Konkhmer Sleokchher para texto de botão
    labelLarge: GoogleFonts.konkhmerSleokchher(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );

  /// Tema principal (Light)
  static ThemeData get mainTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Cores principais
      scaffoldBackgroundColor: AppColors.scaffoldWhite,
      primaryColor: AppColors.navyBlue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navyBlue,
        brightness: Brightness.light,
        background: AppColors.scaffoldWhite,
        error: AppColors.errorRed,
      ),

      // Tema de fontes
      textTheme: _textTheme,
      
      // Tema dos Campos de Texto (Input)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightGrayBackground, // Fundo cinza claro
        hintStyle: _textTheme.bodyMedium, // Estilo do hint
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none, // Sem borda!
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none, // Sem borda
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.navyBlue, width: 2), // Borda azul ao focar
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.errorRed, width: 1), // Borda vermelha para erro
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        prefixIconColor: AppColors.hintGray,
      ),
      
      // Tema dos Botões Elevados (Ex: ENTRAR)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52), // Botão mais alto
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: _textTheme.labelLarge, // Estilo da fonte do botão
        ),
      ),
      
      // Tema dos Botões de Contorno (Ex: ENTRAR COMO ALUNO)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navyBlue,
          side: const BorderSide(color: AppColors.navyBlue, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: _textTheme.labelLarge?.copyWith(color: AppColors.navyBlue),
        ),
      ),

      // Tema da AppBar (vamos manter o admin consistente)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.navyBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.konkhmerSleokchher(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // NOTE: O Dark Theme foi removido para simplicidade, 
  // já que o novo design é focado no tema claro.
  // Você pode usar o mainTheme e definir o themeMode como ThemeMode.light
}