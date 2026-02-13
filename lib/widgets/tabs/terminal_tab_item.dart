import 'package:flutter/material.dart';

class TerminalTabItem extends StatefulWidget {
  final int index;
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final IconData? icon;
  final Widget? badge;

  const TerminalTabItem({
    super.key,
    required this.index,
    required this.title,
    required this.isActive,
    required this.onTap,
    required this.onClose,
    this.icon,
    this.badge,
  });

  @override
  State<TerminalTabItem> createState() => _TerminalTabItemState();
}

class _TerminalTabItemState extends State<TerminalTabItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: Semantics(
        selected: widget.isActive,
        label: widget.title,
        button: true,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? const Color(0xFF1E1E2E)
                  : _isHovering
                  ? const Color(0xFF313244)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: widget.isActive
                      ? const Color(0xFF89B4FA)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 16,
                    color: widget.isActive
                        ? const Color(0xFFCDD6F4)
                        : const Color(0xFF6C7086),
                  ),
                  const SizedBox(width: 8),
                ],
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: Tooltip(
                    message: widget.title,
                    preferBelow: false,
                    verticalOffset: 10,
                    margin: EdgeInsets.zero,
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.isActive
                            ? const Color(0xFFCDD6F4)
                            : const Color(0xFF6C7086),
                        fontSize: 12,
                        fontWeight: widget.isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                if (widget.badge != null) ...[
                  const SizedBox(width: 8),
                  widget.badge!,
                ],
                const SizedBox(width: 8),
                Center(
                  child: Text(
                    '[${widget.index + 1}]',
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color(0xFF6C7086),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                _buildCloseButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return _CloseButton(onClose: widget.onClose);
  }
}

class _CloseButton extends StatefulWidget {
  final VoidCallback onClose;

  const _CloseButton({required this.onClose});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Close tab',
      button: true,
      child: GestureDetector(
        onTap: widget.onClose,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _isHovering ? const Color(0xFF45475A) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.close,
              size: 14,
              color: _isHovering
                  ? const Color(0xFFF38BA8)
                  : const Color(0xFF6C7086),
            ),
          ),
        ),
      ),
    );
  }
}
