# Changelog

## v1.0.1
**Release Date:** 2026-02-13

### New Features
- **Dynamic Tab Titles**: Tabs now automatically synchronize their titles with the current shell path or process name.
- **Enhanced Tab UI**: Introduced a new, fully responsive tab system with support for icons and notification badges.
- **Accessibility Support**: Implemented comprehensive accessibility semantics (WCAG compliant) for tab navigation and interaction.

### Improvements
- **Sanitization Logic**: Added robust validation for terminal titles to strip control characters and handle empty states gracefully.
- **Architecture**: Refactored tab management into reusable widgets (`TerminalTabBar`, `TerminalTabItem`) for better maintainability and performance.
- **Smooth Transitions**: Added animation support for tab switching and state changes.

### Technical Details
- Integrated `xterm` title change events for real-time updates.
- Added unit tests for title sanitization and widget tests for tab components.

---

## v1.0.0
**Latest Zytra Terminal v1.0.0 - Initial Release**

### Overview
Zytra Terminal is a modern, feature-rich terminal emulator built with Flutter for Linux. This is the inaugural release featuring a sleek interface with native window management, tabbed sessions, and system-wide hotkey support.

### New Features
- **Tabbed Terminal Sessions**: Manage multiple terminal instances with easy switching between tabs
- **Custom Window Controls**: Modern minimize, maximize, and close buttons with custom styling
- **System-Wide Hotkeys**:
    - `Ctrl+T`: Open a new terminal tab
    - `Ctrl+W`: Close the current tab
    - `Ctrl+Shift+T`: Restore the last closed tab
    - `F11`: Toggle fullscreen mode
- **Double-Click Maximize**: Intuitive window management by double-clicking the title bar
- **Catppuccin Mocha Theme**: Beautiful, carefully selected color scheme for reduced eye strain
- **Full PTY Support**: Complete pseudo-terminal support for interactive applications like vim, neovim, and other TUI programs
- **Responsive Terminal**: Automatic window resize handling with proper SIGWINCH signal support
- **Custom Title Bar**: Modern draggable title bar with window control buttons

### Technical Highlights
- Built with Flutter for cross-platform potential
- Bidirectional PTY communication for seamless shell interaction
- Efficient terminal rendering using the xterm library
- System tray integration with `tray_manager`
- Global hotkey registration via `hotkey_manager`

### System Requirements
- Linux (Ubuntu 20.04 or later recommended)
- 64-bit processor
- 100MB disk space

### Installation
1. Download the latest release binary
2. Extract the archive
3. Run `./zytra_terminal` or use your application menu

### Known Limitations
- Linux only
- Tab history restore not yet fully implemented
- Single window instance per application launch
