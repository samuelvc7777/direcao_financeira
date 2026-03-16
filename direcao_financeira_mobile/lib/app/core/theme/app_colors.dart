import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Inspiradas na Paleta de Investimento)
  static const Color petrol = Color(0xFF011F26);     // Darkest Teal - Fundo / Deep contrast
  static const Color teal = Color(0xFF038C8C);       // Primary Teal - Ações principais
  static const Color aqua = Color(0xFF03A696);       // Secondary Teal - Destaques
  static const Color sand = Color(0xFFF2B366);       // Warning / Gold Accent - Destaques/Alertas
  static const Color rust = Color(0xFFBF4124);       // Error / Danger - Saídas/Alertas críticos

  // Primary & Brand Mapping
  static const Color primary = teal;
  static const Color secondary = aqua;
  static const Color accent = sand;
  
  // Neutral / Backgrounds
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color backgroundDark = petrol;        // Usando o Petrol para Dark Mode real
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF022C35); // Variação do Petrol

  // Semantic
  static const Color success = aqua;
  static const Color error = rust;
  static const Color warning = sand;
  static const Color info = Color(0xFF3B82F6); 

  // Text
  static const Color textPrimary = petrol;           // Texto principal escuro
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textLight = Color(0xFF94A3B8);  // Slate 400
  
  // Dark Mode Text
  static const Color textPrimaryDark = Color(0xFFF1F5F9); 
  static const Color textSecondaryDark = Color(0xFF94A3B8); 
}
