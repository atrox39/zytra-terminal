import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xterm/xterm.dart';
import 'package:zytra_terminal/schemas/terminal_tab.dart';
import 'package:zytra_terminal/widgets/tabs/terminal_tab_bar.dart';
import 'package:zytra_terminal/utils/terminal_utils.dart';

class TerminalWindow extends StatefulWidget {
  const TerminalWindow({super.key});

  @override
  State createState() => _TerminalWindowState();
}

class _TerminalWindowState extends State<TerminalWindow> with WindowListener {
  List<TerminalTab> tabs = [];
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _registerHotkeys();
    _createNewTab();
  }

  String _currentPathName() {
    return Directory.current.path;
  }

  void _registerHotkeys() {
    hotKeyManager.register(
      HotKey(
        key: PhysicalKeyboardKey.keyT,
        modifiers: [HotKeyModifier.control],
        scope: HotKeyScope.system,
      ),
      keyDownHandler: (_) => _createNewTab(),
    );

    hotKeyManager.register(
      HotKey(
        key: PhysicalKeyboardKey.keyW,
        modifiers: [HotKeyModifier.control],
        scope: HotKeyScope.system,
      ),
      keyDownHandler: (_) => _closeCurrentTab(),
    );

    hotKeyManager.register(
      HotKey(
        key: PhysicalKeyboardKey.keyT,
        modifiers: [HotKeyModifier.control, HotKeyModifier.shift],
        scope: HotKeyScope.system,
      ),
      keyDownHandler: (_) => _restoreTab(),
    );

    hotKeyManager.register(
      HotKey(key: PhysicalKeyboardKey.f11, scope: HotKeyScope.system),
      keyDownHandler: (_) => _toggleFullscreen(),
    );
  }

  void _createNewTab() {
    final tab = TerminalTab(
      id: DateTime.now().millisecondsSinceEpoch,
      terminal: Terminal(maxLines: 10000),
      title: _currentPathName(),
      icon: Icons.terminal,
    );

    _startShell(tab);

    setState(() {
      tabs.add(tab);
      currentTabIndex = tabs.length - 1;
    });
  }

  void _startShell(TerminalTab tab) async {
    String shell = '/bin/bash';
    if (!File(shell).existsSync()) {
      shell = '/bin/sh';
    }

    final pty = Pty.start(
      shell,
      arguments: ['-l'],
      columns: 80,
      rows: 24,
      environment: {
        'TERM': 'xterm-256color',
        'COLORTERM': 'truecolor',
        'HOME': Platform.environment['HOME'] ?? '/',
        'PATH': Platform.environment['PATH'] ?? '/usr/bin:/bin',
        'USER': Platform.environment['USER'] ?? 'user',
      },
      workingDirectory: Platform.environment['HOME'] ?? '/',
    );

    tab.pty = pty;

    pty.output.cast<List<int>>().transform(utf8.decoder).listen((data) {
      tab.terminal.write(data);
    });

    tab.terminal.onOutput = (data) {
      pty.write(const Utf8Encoder().convert(data));
    };

    tab.terminal.onTitleChange = (title) {
      final sanitized = TerminalUtils.sanitizeTitle(title);
      if (mounted && tab.title != sanitized) {
        setState(() {
          tab.title = sanitized;
        });
      }
    };

    tab.terminal.onResize = (width, height, pixelWidth, pixelHeight) {
      pty.resize(height, width);
    };

    pty.exitCode.then((code) {
      if (mounted && tabs.contains(tab)) {
        setState(() {
          tab.terminal.write('\r\n[Process exited with code $code]');
        });
        Future.delayed(Duration(milliseconds: 500), () => _closeCurrentTab());
      }
    });
  }

  void _closeCurrentTab() {
    if (tabs.isEmpty) return;
    _closeTab(currentTabIndex);
  }

  void _closeTab(int index) {
    if (index < 0 || index >= tabs.length) return;

    final tab = tabs[index];
    tab.pty?.kill();

    setState(() {
      tabs.removeAt(index);
      if (currentTabIndex >= tabs.length) {
        currentTabIndex = tabs.length - 1;
      } else if (currentTabIndex > index) {
        currentTabIndex--;
      }

      if (tabs.isEmpty) {
        windowManager.close();
      }
    });
  }

  void _restoreTab() {}

  void _toggleFullscreen() async {
    bool isFullscreen = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!isFullscreen);
  }

  Future<bool> _validateTabChange(int newIndex) async {
    return true;
  }

  void _handleTabSelected(int index) async {
    if (await _validateTabChange(index)) {
      setState(() {
        currentTabIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      body: Column(
        children: [
          //_buildTitleBar(),
          if (tabs.isNotEmpty)
            TerminalTabBar(
              tabs: tabs,
              selectedIndex: currentTabIndex,
              onTabSelected: _handleTabSelected,
              onTabClosed: _closeTab,
              onNewTab: _createNewTab,
              windowManager: windowManager,
            ),
          Expanded(
            child: IndexedStack(
              index: currentTabIndex,
              children: tabs
                  .map(
                    (tab) => TerminalView(
                      tab.terminal,
                      controller: TerminalController(),
                      autofocus: true,
                      backgroundOpacity: 1.0,
                      theme: TerminalTheme(
                        cursor: const Color(0xFFF5E0DC),
                        selection: const Color(0xFF353749),
                        foreground: const Color(0xFFCDD6F4),
                        background: const Color(0xFF1E1E2E),
                        black: const Color(0xFF45475A),
                        red: const Color(0xFFF38BA8),
                        green: const Color(0xFFA6E3A1),
                        yellow: const Color(0xFFF9E2AF),
                        blue: const Color(0xFF89B4FA),
                        magenta: const Color(0xFFF5C2E7),
                        cyan: const Color(0xFF94E2D5),
                        white: const Color(0xFFBAC2DE),
                        brightBlack: const Color(0xFF585B70),
                        brightRed: const Color(0xFFF38BA8),
                        brightGreen: const Color(0xFFA6E3A1),
                        brightYellow: const Color(0xFFF9E2AF),
                        brightBlue: const Color(0xFF89B4FA),
                        brightMagenta: const Color(0xFFF5C2E7),
                        brightCyan: const Color(0xFF94E2D5),
                        brightWhite: const Color(0xFFA6ADC8),
                        searchHitBackground: const Color(0xFF313244),
                        searchHitBackgroundCurrent: const Color(0xFF45475A),
                        searchHitForeground: const Color(0xFFCDD6F4),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onWindowClose() {
    for (var tab in tabs) {
      tab.pty?.kill();
    }
    super.onWindowClose();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    hotKeyManager.unregisterAll();
    super.dispose();
  }
}
