## How to use - Setup Guide

> **Important (Windows users):**  
> This project uses a Bash script. Please run all commands using **Git Bash**, not PowerShell or CMD.

---

### Prerequisites

Before running the setup script, make sure you have:

- **Node.js (LTS)** installed
- **npm / yarn / pnpm** available in your PATH
- An existing, newly created **React Native project**
- **Git Bash** (Windows only)

---

### Quick Setup Guide

This is **one-command setup**.  
Use this if you want the fastest install with zero configuration.

#### Step 1

Navigate into your React Native project directory:

```bash
cd your-project-name
```

#### Step 2

Run the setup script:

```bash
curl -fsSL https://raw.githubusercontent.com/fersonull/rn-dependency-installer/main/setup-v2.sh | bash
```

This will run the script and setup your environment. After that, you can now start developing you ReactNative project.

---

### Previous Version

If you encounter any error while using this latest version of the script, you can still use the previous version:

```bash
curl -fsSL https://raw.githubusercontent.com/fersonull/rn-dependency-installer/main/setup.sh | bash
```
