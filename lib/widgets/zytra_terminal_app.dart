import 'package:flutter/material.dart';
import 'package:zytra_terminal/windows/terminal_window.dart';

class ZytraTerminalApp extends StatelessWidget {
  const ZytraTerminalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zytra Terminal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF1E1E2E),
      ),
      home: TerminalWindow(),
    );
  }
}
