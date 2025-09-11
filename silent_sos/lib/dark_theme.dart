import 'package:flutter/material.dart';

class DarkTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.black,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Colors.deepPurple,
      secondary: Colors.amber,
      background: Colors.black,
      surface: Colors.grey,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.deepPurple,
      textTheme: ButtonTextTheme.primary,
    ),
  );
}