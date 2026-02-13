# Zytra Terminal

A modern, feature-rich terminal emulator built with Flutter for Linux. Zytra Terminal provides a sleek interface with native window management, tabbed sessions, and system-wide hotkey support.

## Features

- **Tabbed Interface** - Manage multiple terminal sessions with easy tab switching
- **Custom Window Controls** - Minimize, maximize, and close with a modern UI
- **System Hotkeys**
  - `Ctrl+T` - Open a new terminal tab
  - `Ctrl+W` - Close current tab
  - `Ctrl+Shift+T` - Restore closed tab
  - `F11` - Toggle fullscreen mode
- **Double-Click Maximize** - Double-click the title bar to maximize/restore
- **Catppuccin Theme** - Beautiful color scheme with Catppuccin Mocha colors
- **PTY Support** - Full pseudo-terminal support for interactive applications like vim/neovim
- **Responsive Terminal** - Automatic window resize handling for terminal applications

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Linux development tools
- Required system libraries:
  ```bash
  sudo apt-get install -y libkeybinder-3.0-dev libayatana-appindicator3-dev
  ```

### Building

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run -v
   ```
4. Build release binary:
   ```bash
   flutter build linux --release
   ```

## Project Structure

- `lib/main.dart` - Main application code with terminal implementation
- `linux/` - Linux platform-specific configuration
- `pubspec.yaml` - Flutter dependencies and project configuration

## Dependencies

- **xterm** - Terminal emulation
- **flutter_pty** - PTY (pseudo-terminal) support
- **window_manager** - Native window management
- **hotkey_manager** - System-wide hotkey registration
- **tray_manager** - System tray integration

## Architecture

The application uses a tabbed architecture where each tab runs an independent shell session through a PTY. The Terminal widget handles rendering, and PTY communication is managed through stream listeners for bidirectional data flow between the UI and shell process.

## License

This project is open source.
