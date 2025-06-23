import 'package:flutter/material.dart';

class FigmaColors {
  const FigmaColors();

  static const Color parkir = Color(0xFFFF9030); // oranye
  static const Color primer = Color(0xFFD2BC47); // kuning emas
  static const Color background = Color(0xFFF3EFCB); // warna latar
  static const Color field = Color(0xFFE0E0E0); // warna untuk textfield (abu terang)
}

class FigmaTextStyles {
  const FigmaTextStyles();

  static const TextStyle heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: Colors.black,
  );

  static const TextStyle hint = TextStyle(
    fontSize: 14,
    color: Colors.black54,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
