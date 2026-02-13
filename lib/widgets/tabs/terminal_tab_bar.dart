import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zytra_terminal/schemas/terminal_tab.dart';
import 'package:zytra_terminal/widgets/tabs/terminal_tab_item.dart';
import 'package:zytra_terminal/widgets/window_button.dart';

class TerminalTabBar extends StatelessWidget {
  final List<TerminalTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final ValueChanged<int> onTabClosed;
  final VoidCallback onNewTab;
  final WindowManager windowManager;

  const TerminalTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onTabClosed,
    required this.onNewTab,
    required this.windowManager,
  });

  @override
  Widget build(BuildContext context) {
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
        height: 40,
        color: const Color(0xFF181825),
        child: Row(
          children: [
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tabs.length,
                itemBuilder: (context, index) {
                  final tab = tabs[index];
                  return TerminalTabItem(
                    index: index,
                    title: tab.title,
                    isActive: index == selectedIndex,
                    icon: tab.icon,
                    badge: tab.badge,
                    onTap: () => onTabSelected(index),
                    onClose: () => onTabClosed(index),
                  );
                },
              ),
            ),
            _NewTabButton(onPressed: onNewTab),
            WindowButton(
              icon: Icons.remove,
              onPressed: () => windowManager.minimize(),
              hoverColor: const Color(0xFF313244),
            ),
            WindowButton(
              icon: Icons.crop_square,
              onPressed: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              },
              hoverColor: const Color(0xFF313244),
            ),
            WindowButton(
              icon: Icons.close,
              onPressed: () => windowManager.close(),
              hoverColor: const Color(0xFFF38BA8),
              iconColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _NewTabButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _NewTabButton({required this.onPressed});

  @override
  State<_NewTabButton> createState() => _NewTabButtonState();
}

class _NewTabButtonState extends State<_NewTabButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'New tab',
      button: true,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: Container(
            width: 40,
            height: 40,
            color: _isHovering ? const Color(0xFF313244) : Colors.transparent,
            child: Icon(
              Icons.add,
              size: 20,
              color: _isHovering
                  ? const Color(0xFFCDD6F4)
                  : const Color(0xFF6C7086),
            ),
          ),
        ),
      ),
    );
  }
}
