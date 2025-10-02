import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/config.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class ThemeToggled extends ThemeEvent {}

class ThemeLoaded extends ThemeEvent {}

// States
class ThemeState extends Equatable {
  final ThemeData themeData;
  final bool isDarkMode;

  const ThemeState({
    required this.themeData,
    required this.isDarkMode,
  });

  @override
  List<Object?> get props => [themeData, isDarkMode];
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc()
      : super(ThemeState(
          themeData: _lightTheme,
          isDarkMode: false,
        )) {
    on<ThemeToggled>(_onThemeToggled);
    on<ThemeLoaded>(_onThemeLoaded);
  }

  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(ThemeColors.primaryLight),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(ThemeColors.backgroundLight),
    cardColor: const Color(ThemeColors.surfaceLight),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(ThemeColors.backgroundLight),
      foregroundColor: Colors.black87,
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(ThemeColors.primaryDark),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(ThemeColors.backgroundDark),
    cardColor: const Color(ThemeColors.surfaceDark),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(ThemeColors.backgroundDark),
      foregroundColor: Colors.white,
    ),
  );

  Future<void> _onThemeToggled(
    ThemeToggled event,
    Emitter<ThemeState> emit,
  ) async {
    final isDark = !state.isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    
    emit(ThemeState(
      themeData: isDark ? _darkTheme : _lightTheme,
      isDarkMode: isDark,
    ));
  }

  Future<void> _onThemeLoaded(
    ThemeLoaded event,
    Emitter<ThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    
    emit(ThemeState(
      themeData: isDark ? _darkTheme : _lightTheme,
      isDarkMode: isDark,
    ));
  }
}