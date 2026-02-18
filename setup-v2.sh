#!/usr/bin/env bash
set -e

# =========================
# COLORS & STYLES
# =========================
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"
BOLD="\e[1m"

# =========================
# HELPERS
# =========================
log() {
  echo -e "\n${BLUE}${BOLD}➜ $1${RESET}"
}

warn() {
  echo -e "${YELLOW}${BOLD}⚠ $1${RESET}"
}

success() {
  echo -e "\n${GREEN}${BOLD}✔ $1${RESET}"
}

die() {
  echo -e "${RED}${BOLD}✖ $1${RESET}"
  exit 1
}

# =========================
# PRECHECKS
# =========================
log "Downloading dependencies files..."

curl -fsSL https://raw.githubusercontent.com/fersonull/rn-dependency-installer/main/deps.prod.txt -o deps.prod.txt
curl -fsSL https://raw.githubusercontent.com/fersonull/rn-dependency-installer/main/deps.dev.txt -o deps.dev.txt

log "Running preflight checks..."

command -v npm >/dev/null 2>&1 || die "npm is not installed"
[ -f package.json ] || die "package.json not found"
[ -f deps.prod.txt ] || die "deps.prod.txt not found"
[ -f deps.dev.txt ] || die "deps.dev.txt not found"

# =========================
# PACKAGE MANAGER DETECTION
# =========================
if command -v npm >/dev/null 2>&1; then
  PM="npm"
elif command -v yarn >/dev/null 2>&1; then
  PM="yarn"
else
  PM="pnpm"
fi

log "Using package manager: $PM"

install_prod() {
  case "$PM" in
    pnpm) pnpm add "$@" ;;
    yarn) yarn add "$@" ;;
    npm) npm install "$@" ;;
  esac
}

install_dev() {
  case "$PM" in
    pnpm) pnpm add -D "$@" ;;
    yarn) yarn add -D "$@" ;;
    npm) npm install --save-dev "$@" ;;
  esac
}

# =========================
# READ DEPS FROM FILE
# =========================
read_deps() {
  local file="$1"
  grep -vE '^\s*#|^\s*$' "$file"
}

# =========================
# INSTALL NATIVEWIND
# =========================
log "Installing NativeWind..."
install_prod nativewind react-native-reanimated react-native-safe-area-context@5.4.0

# =========================
# INSTALL PROD DEPS
# =========================
log "Installing production dependencies..."
PROD_DEPS=$(read_deps deps.prod.txt)
install_prod $PROD_DEPS

# =========================
# INSTALL DEV DEPS
# =========================
log "Installing dev dependencies..."
DEV_DEPS=$(read_deps deps.dev.txt)
install_dev $DEV_DEPS

# =========================
# TAILWIND SETUP
# =========================
log "Initializing Tailwind..."
npx tailwindcss init -p

log "Writing tailwind.config.js..."
cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./App.{jsx,tsx}", "./src/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {},
  },
  plugins: [],
};
EOF

log "Creating global.css..."
cat > global.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

# =========================
# BABEL CONFIG
# =========================
log "Configuring babel.config.js..."
cat > babel.config.js << 'EOF'
module.exports = {
  presets: ['module:@react-native/babel-preset', 'nativewind/babel'],
  plugins: ['react-native-reanimated/plugin'],
};
EOF

# =========================
# METRO CONFIG
# =========================
log "Configuring metro.config.js..."
cat > metro.config.js << 'EOF'
const { getDefaultConfig, mergeConfig } = require("@react-native/metro-config");
const { withNativeWind } = require("nativewind/metro");

module.exports = withNativeWind(
  mergeConfig(getDefaultConfig(__dirname), {}),
  { input: "./global.css" }
);
EOF

# =========================
# APP ENTRY
# =========================
if [ -f App.tsx ] && [ ! -f App.jsx ]; then
  log "Renaming App.tsx → App.jsx"
  mv App.tsx App.jsx
fi

log "Writing App.jsx..."
cat > App.jsx << 'EOF'
import { View, Text } from 'react-native';
import React from 'react';
import "./global.css";

export default function App() {
  return (
    <View className="flex-1 items-center justify-center">
      <Text className="text-2xl font-bold">
        NativeWind is ready 🚀
      </Text>
    </View>
  );
}
EOF

# =========================
# WRITE INSTALLED DEPS
# =========================
log "Writing installed-deps.txt..."
{
  echo "Installed Production Dependencies:"
  for d in $PROD_DEPS; do echo "- $d"; done

  echo ""
  echo "Installed Dev Dependencies:"
  for d in $DEV_DEPS; do echo "- $d"; done

  echo "- nativewind"
} > installed-deps.txt

# =========================
# FINAL STEPS
# =========================
success "INSTALLATION COMPLETE!"

echo -e "\n${BLUE}Next steps:${RESET}"
echo -e "  ${BOLD}npx pod-install ios${RESET}  (macOS only)"
echo -e "  ${BOLD}npm run android${RESET}\n"

echo -e "${YELLOW}GitHub:${RESET} ${BOLD}https://github.com/fersonull${RESET}\n"
