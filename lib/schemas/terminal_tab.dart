import 'package:flutter/widgets.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:xterm/xterm.dart';

class TerminalTab {
  final int id;
  final Terminal terminal;
  Pty? pty;
  String title;
  IconData? icon;
  Widget? badge;

  TerminalTab({
    required this.id,
    required this.terminal,
    this.title = 'Terminal',
    this.icon,
    this.badge,
  });
}
