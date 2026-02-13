import 'package:flutter_pty/flutter_pty.dart';
import 'package:xterm/xterm.dart';

class TerminalTab {
  final int id;
  final Terminal terminal;
  Pty? pty;

  TerminalTab({required this.id, required this.terminal});
}
