# 📜 Changelog

All notable changes to this project will be documented in this file.

This project follows a **pragmatic changelog format** focused on clarity and usability.

---

## [2.0.1] – PowerShell Native Support

### Added

- Native PowerShell (.ps1) installer script for Windows users

### Kept (Backward Compatibility)

- Original one-command setup script (`setup.sh`) and (`setup-v2.sh`) is still supported
- No breaking changes for users relying on the old installer

---

## [Unreleased]

- Planned improvements
- Possible PowerShell support
- Optional dry-run mode
- Re-run optimization (skip already installed deps)

---

## [2.0.0] – Advanced Installer Release

### Added

- File-based dependency management using:
  - `deps.prod.txt`
  - `deps.dev.txt`
- Automatic package manager detection:
  - `npm`
  - `yarn`
  - `pnpm`
- Separation of **production** and **development** dependencies
- Preflight checks for:
  - `package.json`
  - required dependency files
- Auto-generated `installed-deps.txt`
- Improved logging with clear status indicators
- Safer, idempotent script execution
- Better Windows support via **Git Bash**

### Changed

- Dependency lists are no longer hardcoded inside the script
- Babel configuration now includes `react-native-reanimated/plugin` by default
- Installation flow is more modular and maintainable
- README updated with **Quick Setup** and **Advanced Setup** options
- Fetch and download using curl all dependency files (**deps.prod.txt** and **deps.dev.txt**) first instead of directly calling the them

### Kept (Backward Compatibility)

- Original one-command setup script (`setup.sh`) is still supported
- No breaking changes for users relying on the old installer

---

## [1.0.0] – Initial Release

### Added

- One-command setup using `curl | bash`
- NativeWind installation and configuration
- Tailwind CSS initialization
- Babel and Metro configuration
- Automatic React Native dependency installation
- Sample `App.jsx` scaffold
- Beginner-friendly setup flow

---

## Versioning Notes

- **Major versions** indicate installer architecture changes
- **Minor versions** add features without breaking existing usage
- **Patch versions** include bug fixes and small improvements

---

Happy coding!  
If you have suggestions or issues, feel free to open a PR or issue.
