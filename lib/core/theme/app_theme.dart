import 'package:flutter/material.dart';

/// Thème Material 3 : bleu de la maquette. Les couleurs des statuts et des
/// priorités sont dans intervention_labels.dart.
ThemeData buildAppTheme() => ThemeData(
      colorSchemeSeed: const Color(0xFF1F5FBF),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
