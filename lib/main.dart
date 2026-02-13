import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xterm/xterm.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar ventana nativa
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(900, 600),
    center: true,
    title: 'Zytra Terminal',
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  await hotKeyManager.unregisterAll();
  
  runApp(ZytraTerminalApp());
}

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
      HotKey(
        key: PhysicalKeyboardKey.f11,
        scope: HotKeyScope.system,
      ),
      keyDownHandler: (_) => _toggleFullscreen(),
    );
  }
  
  void _createNewTab() {
    final tab = TerminalTab(
      id: DateTime.now().millisecondsSinceEpoch,
      terminal: Terminal(
        maxLines: 10000,
      ),
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
    
    tab.terminal.onResize = (width, height, pixelWidth, pixelHeight) {
      pty.resize(height, width);
    };
    
    pty.exitCode.then((code) {
      if (mounted && tabs.contains(tab)) {
        setState(() {
          tab.terminal.write('\r\n[Proceso terminado con código $code]');
        });
      }
    });
  }
  
  void _closeCurrentTab() {
    if (tabs.isEmpty) return;
    
    final tab = tabs[currentTabIndex];
    tab.pty?.kill();
    
    setState(() {
      tabs.removeAt(currentTabIndex);
      if (currentTabIndex >= tabs.length) {
        currentTabIndex = tabs.length - 1;
      }
      if (tabs.isEmpty) {
        windowManager.close();
      }
    });
  }
  
  void _restoreTab() {
    // Implementar historial de pestañas cerradas
  }
  
  void _toggleFullscreen() async {
    bool isFullscreen = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!isFullscreen);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2E),
      body: Column(
        children: [
          _buildTitleBar(),
          
          if (tabs.length > 1) _buildTabBar(),
          
          Expanded(
            child: IndexedStack(
              index: currentTabIndex,
              children: tabs.map((tab) => TerminalView(
                tab.terminal,
                controller: TerminalController(),
                autofocus: true,
                backgroundOpacity: 1.0,
                theme: TerminalTheme(
                  cursor: Color(0xFFF5E0DC),
                  selection: Color(0xFF353749),
                  foreground: Color(0xFFCDD6F4),
                  background: Color(0xFF1E1E2E),
                  black: Color(0xFF45475A),
                  red: Color(0xFFF38BA8),
                  green: Color(0xFFA6E3A1),
                  yellow: Color(0xFFF9E2AF),
                  blue: Color(0xFF89B4FA),
                  magenta: Color(0xFFF5C2E7),
                  cyan: Color(0xFF94E2D5),
                  white: Color(0xFFBAC2DE),
                  brightBlack: Color(0xFF585B70),
                  brightRed: Color(0xFFF38BA8),
                  brightGreen: Color(0xFFA6E3A1),
                  brightYellow: Color(0xFFF9E2AF),
                  brightBlue: Color(0xFF89B4FA),
                  brightMagenta: Color(0xFFF5C2E7),
                  brightCyan: Color(0xFF94E2D5),
                  brightWhite: Color(0xFFA6ADC8),
                  searchHitBackground: Color(0xFF313244),
                  searchHitBackgroundCurrent: Color(0xFF45475A),
                  searchHitForeground: Color(0xFFCDD6F4),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTitleBar() {
    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      onDoubleTap: () async {
        if (await windowManager.isMaximized()) {
          windowManager.unmaximize();
        } else {
          windowManager.maximize();
        }
      },
      child: Container(
        height: 38,
        color: Color(0xFF181825),
        child: Row(
          children: [
            SizedBox(width: 12),
            Text(
              'Zytra Terminal',
              style: TextStyle(
                color: Color(0xFFCDD6F4),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
            _WindowButton(
              icon: Icons.remove,
              onPressed: () => windowManager.minimize(),
              hoverColor: Color(0xFF313244),
            ),
            _WindowButton(
              icon: Icons.crop_square,
              onPressed: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              },
              hoverColor: Color(0xFF313244),
            ),
            _WindowButton(
              icon: Icons.close,
              onPressed: () => windowManager.close(),
              hoverColor: Color(0xFFF38BA8),
              iconColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTabBar() {
    return Container(
      height: 32,
      color: Color(0xFF181825),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isActive = index == currentTabIndex;
          return GestureDetector(
            onTap: () => setState(() => currentTabIndex = index),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isActive ? Color(0xFF1E1E2E) : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? Color(0xFF89B4FA) : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Terminal ${index + 1}',
                    style: TextStyle(
                      color: isActive ? Color(0xFFCDD6F4) : Color(0xFF6C7086),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 8),
                  if (tabs.length > 1)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (currentTabIndex == index && index > 0) {
                            currentTabIndex--;
                          }
                          tabs[index].pty?.kill();
                          tabs.removeAt(index);
                        });
                      },
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: Color(0xFF6C7086),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
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

class TerminalTab {
  final int id;
  final Terminal terminal;
  Pty? pty;
  
  TerminalTab({required this.id, required this.terminal});
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color hoverColor;
  final Color? iconColor;
  
  const _WindowButton({
    required this.icon,
    required this.onPressed,
    required this.hoverColor,
    this.iconColor,
  });
  
  @override
  __WindowButtonState createState() => __WindowButtonState();
}

class __WindowButtonState extends State<_WindowButton> {
  bool isHovering = false;
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 46,
          height: 38,
          decoration: BoxDecoration(
            color: isHovering ? widget.hoverColor : Colors.transparent,
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: widget.iconColor ?? Color(0xFFCDD6F4),
          ),
        ),
      ),
    );
  }
}
