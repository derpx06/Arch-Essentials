# Arch-Essentials

**Make Arch Linux Easy to Use and Customize**

Arch-Essentials is a comprehensive collection of shell scripts designed to help you keep your Arch Linux system running smoothly. Whether it's checking drivers, ensuring package integrity, or debugging system issues, this project provides modular, user-friendly tools to make your Arch experience effortless.

![Screenshot From 2025-02-26 15-24-28](https://github.com/user-attachments/assets/e2206463-e070-4f2c-bb72-d0f5d7bde992)
---

## Features

- **Modular Design:**  
  Each component is separated into individual scripts that you can customize or extend.

- **Interactive Menus:**  
  Easily navigate through options using [fzf](https://github.com/junegunn/fzf) for a modern, interactive terminal experience.

- **System Diagnostics:**  
  Quickly check system health, including drivers, package integrity (like `pacman-key`), and more.

- **Deep Debug Options:**  
  A dedicated deep debug mode to run comprehensive system checks and apply fixes where needed.

---

## Installation

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/manas1511200/Arch-Essentials.git
   cd Arch-Essentials
   ```

2. **Install Dependencies:**

   Ensure you have [fzf](https://github.com/junegunn/fzf), [lshw](https://en.wikipedia.org/wiki/Lshw), and other required tools installed:

   ```bash
   sudo pacman -Syu fzf lshw
   ```

3. **Make the Scripts Executable:**

   ```bash
   chmod +x arch_essentials.sh
   chmod +x ./scripts/*.sh
   sudo ./arch_essentials.sh
   ```

---

## Usage

Launch the main menu with:

```bash
./arch_essentials.sh
```

From the main menu, select options like **Customize**, **Update**, **Debug**, **Cleanup**, **Network**, or **System Info**.  
- **Deep Debug:** Under the **Debug** submenu, the *Deep Debug* option will run comprehensive checks, including verifying drivers, package integrity, pacman-key, and more.

---

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests.Many features dont work properly as off now

---
---

*Happy Arch-ing and enjoy a hassle-free, customized Arch Linux experience!Use Arch BTW*

