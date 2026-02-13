#!/bin/bash

set -e

PROJECT_NAME="zytra_terminal"
VERSION="1.0.0"
BUILD_DIR="build/linux/x64/release/bundle"

echo "=== Building Zytra Terminal ==="

flutter clean

flutter pub get

flutter build linux --release

if [ ! -f "$BUILD_DIR/$PROJECT_NAME" ]; then
    echo "Error: Executable not found at $BUILD_DIR/$PROJECT_NAME"
    exit 1
fi

DIST_DIR="dist/zytra-terminal-$VERSION-linux-x64"
mkdir -p "$DIST_DIR"

cp -r "$BUILD_DIR"/* "$DIST_DIR/"

cat > "$DIST_DIR/zytra-terminal" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LD_LIBRARY_PATH="$SCRIPT_DIR/lib:$LD_LIBRARY_PATH"
"$SCRIPT_DIR/zytra_terminal" "$@"
EOF
chmod +x "$DIST_DIR/zytra-terminal"

mkdir -p "$DIST_DIR/usr/share/applications"
cat > "$DIST_DIR/usr/share/applications/zytra-terminal.desktop" << EOF
[Desktop Entry]
Name=Zytra Terminal
Comment=Terminal emulator for Zytra OS
Exec=/usr/bin/zytra-terminal
Icon=zytra-terminal
Type=Application
Terminal=false
Categories=System;TerminalEmulator;
EOF

tar czf "dist/zytra-terminal-$VERSION-linux-x64.tar.gz" -C dist "zytra-terminal-$VERSION-linux-x64"

echo "=== Build ==="
echo "Location: $DIST_DIR"
echo "Executable: $DIST_DIR/zytra-terminal"
