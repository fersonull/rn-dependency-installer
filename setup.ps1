# =========================
# STRICT MODE
# =========================
$ErrorActionPreference = "Stop"

# =========================
# COLORS & STYLES
# =========================
function Log($message) {
    Write-Host "`n➜ $message" -ForegroundColor Blue
}

function Warn($message) {
    Write-Host "⚠ $message" -ForegroundColor Yellow
}

function Success($message) {
    Write-Host "`n✔ $message" -ForegroundColor Green
}

function Die($message) {
    Write-Host "✖ $message" -ForegroundColor Red
    exit 1
}

# =========================
# PRECHECKS
# =========================
Log "Downloading dependencies files..."

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/fersonull/rn-dependency-installer/main/deps.prod.txt" -OutFile "deps.prod.txt"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/fersonull/rn-dependency-installer/main/deps.dev.txt" -OutFile "deps.dev.txt"

Log "Running preflight checks..."

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Die "npm is not installed"
}

if (-not (Test-Path "package.json")) {
    Die "package.json not found"
}

if (-not (Test-Path "deps.prod.txt")) {
    Die "deps.prod.txt not found"
}

if (-not (Test-Path "deps.dev.txt")) {
    Die "deps.dev.txt not found"
}

# =========================
# PACKAGE MANAGER DETECTION
# =========================
if (Get-Command pnpm -ErrorAction SilentlyContinue) {
    $PM = "pnpm"
}
elseif (Get-Command yarn -ErrorAction SilentlyContinue) {
    $PM = "yarn"
}
else {
    $PM = "npm"
}

Log "Using package manager: $PM"

function Install-Prod($packages) {
    switch ($PM) {
        "pnpm" { pnpm add $packages }
        "yarn" { yarn add $packages }
        "npm"  { npm install $packages }
    }
}

function Install-Dev($packages) {
    switch ($PM) {
        "pnpm" { pnpm add -D $packages }
        "yarn" { yarn add -D $packages }
        "npm"  { npm install --save-dev $packages }
    }
}

# =========================
# READ DEPS FROM FILE
# =========================
function Read-Deps($file) {
    Get-Content $file |
        Where-Object { $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$' }
}

# =========================
# INSTALL NATIVEWIND
# =========================
Log "Installing NativeWind..."
Install-Prod @("nativewind", "react-native-reanimated", "react-native-safe-area-context@5.4.0")

# =========================
# INSTALL PROD DEPS
# =========================
Log "Installing production dependencies..."
$PROD_DEPS = Read-Deps "deps.prod.txt"
Install-Prod $PROD_DEPS

# =========================
# INSTALL DEV DEPS
# =========================
Log "Installing dev dependencies..."
$DEV_DEPS = Read-Deps "deps.dev.txt"
Install-Dev $DEV_DEPS

# =========================
# TAILWIND SETUP
# =========================
Log "Initializing Tailwind..."
npx tailwindcss init -p

Log "Writing tailwind.config.js..."
@"
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./App.{jsx,tsx}", "./src/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {},
  },
  plugins: [],
};
"@ | Set-Content tailwind.config.js

Log "Creating global.css..."
@"
@tailwind base;
@tailwind components;
@tailwind utilities;
"@ | Set-Content global.css

# =========================
# BABEL CONFIG
# =========================
Log "Configuring babel.config.js..."
@"
module.exports = {
  presets: ['module:@react-native/babel-preset', 'nativewind/babel'],
  plugins: ['react-native-reanimated/plugin'],
};
"@ | Set-Content babel.config.js

# =========================
# METRO CONFIG
# =========================
Log "Configuring metro.config.js..."
@"
const { getDefaultConfig, mergeConfig } = require("@react-native/metro-config");
const { withNativeWind } = require("nativewind/metro");

module.exports = withNativeWind(
  mergeConfig(getDefaultConfig(__dirname), {}),
  { input: "./global.css" }
);
"@ | Set-Content metro.config.js

# =========================
# APP ENTRY
# =========================
if ((Test-Path "App.tsx") -and -not (Test-Path "App.jsx")) {
    Log "Renaming App.tsx → App.jsx"
    Rename-Item "App.tsx" "App.jsx"
}

Log "Writing App.jsx..."
@"
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
"@ | Set-Content App.jsx

# =========================
# WRITE INSTALLED DEPS
# =========================
Log "Writing installed-deps.txt..."

$Output = @()
$Output += "Installed Production Dependencies:"
$PROD_DEPS | ForEach-Object { $Output += "- $_" }

$Output += ""
$Output += "Installed Dev Dependencies:"
$DEV_DEPS | ForEach-Object { $Output += "- $_" }

$Output += "- nativewind"

$Output | Set-Content installed-deps.txt

# =========================
# FINAL STEPS
# =========================
Success "INSTALLATION COMPLETE!"

Write-Host "`nNext steps:" -ForegroundColor Blue
Write-Host "  npx pod-install ios (macOS only)"
Write-Host "  npm run android`n"

Write-Host "GitHub: https://github.com/fersonull`n" -ForegroundColor Yellow