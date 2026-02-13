#!/bin/bash
# build-zytra-deb.sh - Manual .deb package builder for Zytra Terminal

set -e

APP_NAME="zytra-terminal"
VERSION="1.0.0"
ARCH="amd64"
BUILD_DIR="build/linux/x64/release/bundle"
DEB_ROOT="dist/deb_root"

echo "🔨 Building Zytra Terminal..."

# 1. Clean and build Flutter
echo "→ Compiling Flutter Linux..."
flutter clean
flutter pub get
flutter build linux --release

# 2. Prepare DEB structure
echo "→ Preparing package structure..."
rm -rf "$DEB_ROOT"
mkdir -p "$DEB_ROOT/opt/$APP_NAME"
mkdir -p "$DEB_ROOT/usr/bin"
mkdir -p "$DEB_ROOT/usr/share/applications"
mkdir -p "$DEB_ROOT/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$DEB_ROOT/DEBIAN"

# 3. Copy build files
echo "→ Copying files..."
cp -r "$BUILD_DIR"/* "$DEB_ROOT/opt/$APP_NAME/"

# 4. Create main launcher script
cat > "$DEB_ROOT/opt/$APP_NAME/$APP_NAME" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LD_LIBRARY_PATH="$SCRIPT_DIR/lib:$LD_LIBRARY_PATH"
"$SCRIPT_DIR/zytra_terminal" "$@"
EOF
chmod +x "$DEB_ROOT/opt/$APP_NAME/$APP_NAME"

# 5. Create symbolic link in /usr/bin
ln -sf "/opt/$APP_NAME/$APP_NAME" "$DEB_ROOT/usr/bin/$APP_NAME"

# 6. Create DEBIAN/control file
cat > "$DEB_ROOT/DEBIAN/control" << EOF
Package: $APP_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: $ARCH
Depends: libgtk-3-0, libblkid1, liblzma5, libglfw3, libx11-6, libxrandr2, libxinerama1, libxcursor1, libxi6
Recommends: bash, zsh
Maintainer: Atrox39 <atrox390@gmail.com>
Description: Terminal emulator for Zytra OS
 Zytra Terminal is a modern, fast terminal emulator built with Flutter.
 Features include multiple tabs, custom themes, and hardware acceleration.
EOF

# 7. Create postinst (post-installation)
cat > "$DEB_ROOT/DEBIAN/postinst" << 'EOF'
#!/bin/bash
set -e
echo "✅ Zytra Terminal installed successfully"
echo "   Run: zytra-terminal"
echo "   Or search 'Zytra Terminal' in your applications menu"
EOF
chmod +x "$DEB_ROOT/DEBIAN/postinst"

# 8. Create prerm (pre-removal)
cat > "$DEB_ROOT/DEBIAN/prerm" << 'EOF'
#!/bin/bash
set -e
# Cleanup if necessary
EOF
chmod +x "$DEB_ROOT/DEBIAN/prerm"

# 9. Create desktop entry
cat > "$DEB_ROOT/usr/share/applications/$APP_NAME.desktop" << EOF
[Desktop Entry]
Name=Zytra Terminal
Comment=Modern terminal emulator for Zytra OS
Exec=/opt/$APP_NAME/$APP_NAME
Icon=$APP_NAME
Type=Application
Terminal=false
Categories=System;TerminalEmulator;
Keywords=terminal;console;shell;bash;zytra;
StartupNotify=true
EOF

# 10. Create placeholder icon if missing
if [ ! -f "assets/logo.png" ]; then
    echo "⚠️  Creating placeholder icon..."
    mkdir -p assets
    # Create simple PNG with ImageMagick or download
    convert -size 256x256 xc:"#1E1E2E" -pointsize 120 -fill "#89B4FA" -gravity center -annotate +0+0 "Z" assets/logo.png 2>/dev/null || \
    curl -sL "https://via.placeholder.com/256/1E1E2E/89B4FA?text=Z" -o assets/logo.png
fi
cp "assets/logo.png" "$DEB_ROOT/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png"

# 11. Build .deb package
echo "→ Building .deb package..."
mkdir -p dist
dpkg-deb --build "$DEB_ROOT" "dist/${APP_NAME}_${VERSION}_${ARCH}.deb"

# 12. Verify
echo ""
echo "✅ PACKAGE CREATED SUCCESSFULLY!"
echo "📦 Location: dist/${APP_NAME}_${VERSION}_${ARCH}.deb"
echo "📊 Size: $(du -h dist/${APP_NAME}_${VERSION}_${ARCH}.deb | cut -f1)"
echo ""
echo "🚀 Install with:"
echo "   sudo dpkg -i dist/${APP_NAME}_${VERSION}_${ARCH}.deb"
echo ""
echo "🔍 Verify contents:"
echo "   dpkg -c dist/${APP_NAME}_${VERSION}_${ARCH}.deb"
