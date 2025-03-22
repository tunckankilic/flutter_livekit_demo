import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1A73E8),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF1A73E8),
      secondary: const Color(0xFF188038),
      background: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      color: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: GoogleFonts.roboto(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: GoogleFonts.robotoTextTheme(),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF8AB4F8),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF8AB4F8),
      secondary: const Color(0xFF81C995),
      background: const Color(0xFF202124),
    ),
    scaffoldBackgroundColor: const Color(0xFF202124),
    appBarTheme: AppBarTheme(
      color: const Color(0xFF202124),
      elevation: 0,
      titleTextStyle: GoogleFonts.roboto(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
  );
}
