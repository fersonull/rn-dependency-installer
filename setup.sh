#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

BOLD="\e[1m"

echo -e "\n${BLUE}${BOLD}REACT NATIVE DEPENDENCY INSTALLER SCRIPT${RESET}"

echo -e "\n${YELLOW}Installing ${BOLD}nativewind...${RESET}"
npm install nativewind react-native-reanimated react-native-safe-area-context@5.4.0
npm install --include=dev tailwindcss@^3.4.17 react-native-worklets

echo -e "${BLUE}Creating ${BOLD}tailwind.config.js...${RESET}"
npx tailwindcss init

echo -e "${BLUE}Modifying ${BOLD}tailwind.config.js...${RESET}"
cat << 'EOF' > tailwind.config.js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./App.{jsx,tsx}", "./src/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

echo -e "${BLUE}Creating and modifying ${BOLD}global.css...${RESET}"
cat << 'EOF' > global.css
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

echo -e "${BLUE}Modifying ${BOLD}babel.config.js...${RESET}"
cat << 'EOF' > babel.config.js
module.exports = {
  presets: ['module:@react-native/babel-preset', 'nativewind/babel'],
};
EOF

echo -e "${BLUE}Modifying ${BOLD}metro.config.js...${RESET}"
cat << 'EOF' > metro.config.js
const { getDefaultConfig, mergeConfig } = require("@react-native/metro-config");
const { withNativeWind } = require("nativewind/metro");
 
const config = mergeConfig(getDefaultConfig(__dirname), {
  /* your config */
});
 
module.exports = withNativeWind(config, { input: "./global.css" });
EOF

echo -e "${BLUE}Renaming the ${BOLD}.tsx${RESET}${BLUE} extension to ${BOLD}.jsx${RESET}..."
mv ./App.tsx ./App.jsx

echo -e "${BLUE}Finishing up...${RESET}"
cat << 'EOF' > App.jsx
import { View, Text } from 'react-native'
import React from 'react'
import "./global.css"

export default function App() {
  return (
    <View className='flex-1 items-center justify-center'>
      <Text className='text-2xl font-bold'>You are now set!</Text>
    </View>
  )
}
EOF

echo -e "\n${GREEN}${BOLD}NATIVEWIND INSTALLED!${RESET}\n"

echo -e "${YELLOW}Installing necessary native dependencies...${RESET}"
npm i react-native-reanimated react-native-svg react-native-safe-area-context react-native-screens @react-navigation/native @react-navigation/native-stack @react-navigation/bottom-tabs @react-navigation/drawer react-native-gesture-handler lucide-react-native react-native-bootsplash

cat << 'EOF' > babel.config.js
module.exports = {
  presets: ['module:@react-native/babel-preset', 'nativewind/babel'],
  plugins: ['react-native-reanimated/plugin']
};
EOF

echo -e "\n${GREEN}${BOLD}INSTALLATION FINISHED!${RESET}"

cat << 'EOF' | tee installed-deps.txt
Installed Dependencies:
- tailwindcss
- nativewind
- @react-navigation/native
- @react-navigation/native-stack
- @react-navigation/bottom-tabs
- @react-navigation/drawer
- react-native-screens
- react-native-safe-area-context
- react-native-worklets
- react-native-reanimated
- react-native-gesture-handler
- react-native-svg
- react-native-bootsplash
- lucide-react-native
EOF

echo -e "\nYou can verify see the list of all installed dependencies in ${BOLD}installed-deps.txt${RESET} file"

echo -e "\nrun your project now:${BLUE}${BOLD} npm run android${RESET}"

echo -e "\n${YELLOW}visit and follow my github page for more:${BOLD} https://github.com/fersonull${RESET}"
