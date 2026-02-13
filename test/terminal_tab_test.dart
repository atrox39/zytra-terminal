import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xterm/xterm.dart';
import 'package:zytra_terminal/schemas/terminal_tab.dart';

void main() {
  group('TerminalTab', () {
    test('should initialize with default values', () {
      final terminal = Terminal();
      final tab = TerminalTab(id: 1, terminal: terminal);

      expect(tab.id, 1);
      expect(tab.terminal, terminal);
      expect(tab.title, 'Terminal');
      expect(tab.icon, null);
      expect(tab.badge, null);
      expect(tab.pty, null);
    });

    test('should initialize with provided values', () {
      final terminal = Terminal();
      const icon = IconData(0xe000, fontFamily: 'MaterialIcons');
      const badge = Text('1');

      final tab = TerminalTab(
        id: 2,
        terminal: terminal,
        title: 'Custom Title',
        icon: icon,
        badge: badge,
      );

      expect(tab.id, 2);
      expect(tab.title, 'Custom Title');
      expect(tab.icon, icon);
      expect(tab.badge, badge);
    });
  });
}
