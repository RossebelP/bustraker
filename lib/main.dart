import 'package:flutter/material.dart';

import 'screens/map_screen.dart';

void
main() {
  runApp(
    const BusTrackerApp(),
  );
}

class BusTrackerApp
    extends
        StatefulWidget {
  const BusTrackerApp({
    super.key,
  });

  @override
  State<
    BusTrackerApp
  >
  createState() =>
      _BusTrackerAppState();
}

class _BusTrackerAppState
    extends
        State<
          BusTrackerApp
        > {
  ThemeMode
  _themeMode =
      ThemeMode.dark;

  bool
  get _isDarkMode =>
      _themeMode ==
      ThemeMode.dark;

  void
  _toggleTheme() {
    setState(() {
      _themeMode = _isDarkMode
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget
  build(
    BuildContext
    context,
  ) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus Tracker Trujillo',
      themeMode: _themeMode,
      theme: _buildTheme(
        Brightness.light,
      ),
      darkTheme: _buildTheme(
        Brightness.dark,
      ),
      home: MapScreen(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }

  ThemeData
  _buildTheme(
    Brightness
    brightness,
  ) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(
        0xFF0A84FF,
      ),
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      fontFamily: 'Roboto',
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            48,
            48,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              8,
            ),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              8,
            ),
          ),
        ),
      ),
    );
  }
}
