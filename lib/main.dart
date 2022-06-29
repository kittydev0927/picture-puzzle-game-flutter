import 'package:flutter/material.dart';

import 'widget_puzzle_matrix.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Puzzle',
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }

  void changeTheme() {
    final ThemeMode changeTheme = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setState(() {
      _themeMode = changeTheme;
    });
  }

  ThemeMode getCurrentThemeMode() => _themeMode;
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentThemeMode = MyApp.of(context)!.getCurrentThemeMode();
    final floatingActionButtonIcon = currentThemeMode != ThemeMode.dark
        ? const Icon(
            Icons.dark_mode,
            color: Colors.black,
          )
        : const Icon(
            Icons.light_mode,
            color: Colors.white,
          );

    return Scaffold(
      body: Center(
        child: PuzzleMatrixWidget(),
      ),
      floatingActionButton: FloatingActionButton(
        child: floatingActionButtonIcon,
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          MyApp.of(context)!.changeTheme();
        },
      ),
    );
  }
}
