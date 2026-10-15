#!/usr/bin/env bash
set -e

# ==============================================================================
# Linux PDF — Universal Multi-Distro Installer
# Supports: Ubuntu, Debian, Linux Mint, Pop!_OS, Fedora, RHEL, Arch, openSUSE
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

APP_NAME="Linux PDF"
BIN_NAME="linux-pdf"
DESKTOP_FILE="linux-pdf.desktop"
ICON_NAME="linux-pdf"

INSTALL_DIR="/opt/linux-pdf"
BIN_LINK="/usr/local/bin/${BIN_NAME}"
DESKTOP_DIR="/usr/share/applications"
ICON_DIR="/usr/share/icons/hicolor/512x512/apps"

MODE="install"
USER_MODE=0

for arg in "$@"; do
  case $arg in
    --user)
      USER_MODE=1
      INSTALL_DIR="$HOME/.local/share/acrobat-linux"
      BIN_LINK="$HOME/.local/bin/${BIN_NAME}"
      DESKTOP_DIR="$HOME/.local/share/applications"
      ICON_DIR="$HOME/.local/share/icons/hicolor/512x512/apps"
      ;;
    --uninstall)
      MODE="uninstall"
      ;;
    --web)
      MODE="web"
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --install     Install system-wide (requires sudo, default)"
      echo "  --user        Install for current user without sudo"
      echo "  --uninstall   Completely remove Adobe Acrobat Pro"
      echo "  --web         Launch in Universal Web Server mode"
      exit 0
      ;;
  esac
done

if [ "$MODE" = "web" ]; then
  echo -e "${BLUE}${BOLD}Starting Adobe Acrobat Pro in Universal Web Mode...${NC}"
  node electron/main.cjs --web
  exit 0
fi

if [ "$MODE" = "uninstall" ]; then
  echo -e "${YELLOW}${BOLD}Uninstalling Adobe Acrobat Pro...${NC}"
  rm -rf "$INSTALL_DIR"
  rm -f "$BIN_LINK"
  rm -f "$DESKTOP_DIR/$DESKTOP_FILE"
  rm -f "$ICON_DIR/${ICON_NAME}.png"
  
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
  fi
  echo -e "${GREEN}${BOLD}Adobe Acrobat Pro has been successfully uninstalled.${NC}"
  exit 0
fi

echo -e "${RED}${BOLD}======================================================${NC}"
echo -e "${RED}${BOLD}   Adobe Acrobat Pro Linux Edition — Installer       ${NC}"
echo -e "${RED}${BOLD}======================================================${NC}\n"

# Verify permissions
if [ $USER_MODE -eq 0 ] && [ "$EUID" -ne 0 ]; then
  echo -e "${YELLOW}Notice: System-wide install requires root privileges.${NC}"
  echo -e "Re-running with sudo (or pass --user for local installation)..."
  exec sudo "$0" "$@"
fi

# Detect package manager & install runtime libraries
echo -e "${BLUE}▶ Checking system dependencies...${NC}"
if [ $USER_MODE -eq 0 ]; then
  if command -v apt-get >/dev/null 2>&1; then
    echo "Detected Debian/Ubuntu APT. Ensuring system runtime libraries are installed..."
    apt-get update -qq
    apt-get install -y -qq libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libxkbcommon0 libgbm1 libasound2 xdg-utils >/dev/null 2>&1 || true
  elif command -v dnf >/dev/null 2>&1; then
    echo "Detected Fedora/RHEL DNF. Ensuring runtime libraries..."
    dnf install -y nss atk at-spi2-atk cups-libs libdrm libxkbcommon mesa-libgbm alsa-lib xdg-utils >/dev/null 2>&1 || true
  elif command -v pacman >/dev/null 2>&1; then
    echo "Detected Arch Linux pacman."
    pacman -S --needed --noconfirm nss atk at-spi2-atk libcups libdrm libxkbcommon mesa alsa-lib xdg-utils >/dev/null 2>&1 || true
  fi
fi

# Create target directories
echo -e "${BLUE}▶ Creating application directories...${NC}"
mkdir -p "$INSTALL_DIR"
mkdir -p "$(dirname "$BIN_LINK")"
mkdir -p "$DESKTOP_DIR"
mkdir -p "$ICON_DIR"

# Copy application files
echo -e "${BLUE}▶ Installing application payload to ${INSTALL_DIR}...${NC}"
cp -r assets dist electron package.json "$INSTALL_DIR/"

# Install icon
if [ -f "assets/icon.png" ]; then
  cp "assets/icon.png" "$ICON_DIR/${ICON_NAME}.png"
fi

# Create launcher wrapper script with Wayland + Sandbox auto-detection
cat << 'EOF' > "$BIN_LINK"
#!/usr/bin/env bash
INSTALL_DIR="/opt/acrobat-linux"
[ -d "$HOME/.local/share/acrobat-linux" ] && INSTALL_DIR="$HOME/.local/share/acrobat-linux"

# Detect Wayland
EXTRA_FLAGS=()
if [ -n "$WAYLAND_DISPLAY" ]; then
  EXTRA_FLAGS+=("--ozone-platform-hint=auto" "--enable-features=WaylandWindowDecorations")
fi

# Detect unprivileged namespaces or root
if [ "$EUID" -eq 0 ] || [ -n "$WSL_DISTRO_NAME" ] || [ "$ELECTRON_NO_SANDBOX" = "1" ]; then
  EXTRA_FLAGS+=("--no-sandbox" "--disable-setuid-sandbox")
fi

if command -v electron >/dev/null 2>&1; then
  exec electron "$INSTALL_DIR" "${EXTRA_FLAGS[@]}" "$@"
elif [ -f "$INSTALL_DIR/acrobat-linux" ]; then
  exec "$INSTALL_DIR/acrobat-linux" "${EXTRA_FLAGS[@]}" "$@"
else
  # Web mode fallback if Electron binary is missing
  echo "Native Electron runtime not detected. Starting Universal Web Mode..."
  exec node "$INSTALL_DIR/electron/main.cjs" --web "$@"
fi
EOF

chmod +x "$BIN_LINK"

# Install Desktop Entry
cat << EOF > "$DESKTOP_DIR/$DESKTOP_FILE"
[Desktop Entry]
Name=Adobe Acrobat Pro
GenericName=PDF Editor & Reader
Comment=Complete Adobe Acrobat Pro PDF suite for Linux - View, Edit, Annotate, Sign, Organize, OCR, and Form Fill
Exec=${BIN_NAME} %U
Terminal=false
Type=Application
Icon=${ICON_NAME}
Categories=Office;Viewer;Publishing;Graphics;
MimeType=application/pdf;application/vnd.adobe.pdf;application/x-pdf;application/x-bzpdf;application/x-gzpdf;
Keywords=pdf;reader;viewer;editor;acrobat;adobe;sign;annotate;ocr;organize;
StartupWMClass=acrobat-linux
Actions=NewWindow;WebMode;

[Desktop Action NewWindow]
Name=Open New Window
Exec=${BIN_NAME}

[Desktop Action WebMode]
Name=Open in Web Browser Mode
Exec=${BIN_NAME} --web
EOF

chmod 644 "$DESKTOP_DIR/$DESKTOP_FILE"

# Update desktop & MIME caches
echo -e "${BLUE}▶ Registering MIME types and system caches...${NC}"
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
fi
if command -v update-icon-caches >/dev/null 2>&1; then
  update-icon-caches "$(dirname "$(dirname "$ICON_DIR")")" 2>/dev/null || true
fi
if command -v xdg-mime >/dev/null 2>&1; then
  xdg-mime default "$DESKTOP_FILE" application/pdf 2>/dev/null || true
fi

echo -e "\n${GREEN}${BOLD}======================================================${NC}"
echo -e "${GREEN}${BOLD}✔ Adobe Acrobat Pro Linux installed successfully!   ${NC}"
echo -e "${GREEN}${BOLD}======================================================${NC}"
echo -e "You can launch the application via:"
echo -e "  • Application menu: ${BOLD}Adobe Acrobat Pro${NC}"
echo -e "  • Terminal command: ${BOLD}${BIN_NAME} [file.pdf]${NC}"
echo -e "  • Web Server mode:  ${BOLD}${BIN_NAME} --web${NC}\n"
