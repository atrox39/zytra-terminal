import 'package:flutter/material.dart';

class WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color hoverColor;
  final Color? iconColor;

  const WindowButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.hoverColor,
    this.iconColor,
  });

  @override
  State createState() => __WindowButtonState();
}

class __WindowButtonState extends State<WindowButton> {
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
