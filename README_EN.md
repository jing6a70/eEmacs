<img src="./apex.jpg" title="" alt="" width="724">

# 🚀 Emacs Custom IDE:  C/C++ IDE

## [English](./README_EN.md) / [中文](./README.md)

This is a personalized Emacs configuration repository, designed to turn Emacs into an **out-of-the-box, efficient, and smooth all-purpose programming environment**. It is especially optimized for C/C++ development, balancing usability and powerful features, allowing you to get rid of tedious configurations and focus on coding itself.

### ✨ Core Features

#### 🧠 Intelligent Code Completion & Navigation (LSP Integration)

- Integrates **Language Server Protocol (LSP)** to provide industrial-grade code intelligence support.

- Supports **fuzzy matching code completion** for quickly filtering candidates and greatly improving coding efficiency.

- Full support for core features such as **go to definition, find references, rename, and code diagnostics**, comparable to mainstream IDEs.

#### 🔧 One-Stop C/C++ IDE Solution

- Custom-optimized C/C++ development workflow with **complete project management and efficient code navigation** capabilities.

- Built-in **debugging support**, seamlessly connecting to debugging tools for quickly locating code issues.

- Special optimization for C/C++ syntax highlighting, indentation, and formatting, complying with industrial coding standards.

#### 🚀 Built-in Multi-Language Code Snippets (YASnippet)

- Integrates YASnippet with preset common code templates for multiple mainstream programming languages.

- One-click insertion of code blocks (loops, conditionals, function definitions, comment templates, etc.) to reduce repetitive coding.

- Supports custom extended code snippets to adapt to personal coding habits and project requirements.

#### 📦 Easy Installation, Out-of-the-Box

- No complex environment configuration required; run Emacs directly after cloning.

- Compatible with Emacs 29+ native `use-package`; provides a simple supplementary installation solution for lower versions.

### 🛠 Quick Installation

#### 1. Clone the Configuration Repository

Clone the repository directly to the `~/.emacs.d` directory (overwrites existing configuration; back up important data in advance):

```bash
git clone https://github.com/jing6a70/emacs.git ~/.emacs.d
```

#### 2. Run Emacs

After cloning, start Emacs directly in the terminal or desktop environment:

```bash
emacs
```

#### 3. Compatibility for Older Emacs Versions (< 29)

Emacs 29 comes with the core dependency `use-package` natively. For versions below 29, manually install it after starting Emacs:

1. Press the shortcut `Alt + x` (to invoke the M-x command panel).

2. Enter the following command and press Enter, then wait for the installation to complete:

```elisp
package-install use-package
```

### 🔌 System Dependencies

Emacs packages install automatically on first launch, but some features rely on **system-level tools**. Install what you need (Arch Linux / Ubuntu commands below).

#### Base Tools

| Purpose | Arch Linux | Ubuntu | Suggestion |
| --- | --- | --- | --- |
| Spell checking (flyspell, fix a word with `M-$`) | `sudo pacman -S aspell aspell-en` | `sudo apt install aspell aspell-en` | Recommended |
| Global search (`M-s r` consult-ripgrep) | `sudo pacman -S ripgrep` | `sudo apt install ripgrep` | Recommended |
| Git integration (magit / diff-hl / forge) | `sudo pacman -S git` | `sudo apt install git` | Recommended |
| Treemacs async git status | `sudo pacman -S python3` | `sudo apt install python3` | Optional |
| CMake projects (`<f6>` regenerates compile_commands.json) | `sudo pacman -S cmake` | `sudo apt install cmake` | Optional |
| Org LaTeX preview (dvisvgm) | `sudo pacman -S dvisvgm texlive-basic` | `sudo apt install texlive-extra-utils texlive-latex-base` | Optional |
| Node.js (dependency of bash-language-server / pyright) | `sudo pacman -S nodejs npm` | `sudo apt install nodejs npm` | As needed |
| Go toolchain (dependency of gopls) | `sudo pacman -S go` | `sudo apt install golang-go` | As needed |

#### LSP Servers (install per language you use)

```bash
# C/C++ — clangd (bundled with the clang package on Arch; dedicated package on Ubuntu)
sudo pacman -S clang        # Arch
sudo apt install clangd     # Ubuntu

# Shell — bash-language-server (requires nodejs + npm)
npm install -g --prefix ~/.local/npm-global bash-language-server

# Python — pyright (requires nodejs + npm)
npm install -g --prefix ~/.local/npm-global pyright

# Go — gopls (requires the Go toolchain)
go install golang.org/x/tools/gopls@latest
```

> **Path convention**: the config automatically adds `~/.local/npm-global/bin` and `~/go/bin` to Emacs's `exec-path` (see `elisp/e-bash-mode.el`, `elisp/e-golang-mode.el`), so installing the servers to these default locations just works; no shell environment changes needed. A missing server only produces a warning when opening a file of that language and does not affect other languages.

#### Fonts (icon display)

The treemacs and doom-modeline icons require any **Nerd Font**:

```bash
# Arch (AUR)
yay -S nerd-fonts-fira-code

# Manual: download from https://github.com/ryanoasis/nerd-fonts/releases,
# drop the font into ~/.local/share/fonts, then run fc-cache -fv
```

The default font setting lives in `view/use-fonts.el` (commented out by default; enable as needed).

### 📂 Project Directory Structure

```plain
~/.emacs.d/
├── core/        # Core configuration files (initialization, global settings, etc.)
├── moduls/      # Independent configuration items for each plugin (on-demand loading, personalized settings)
├── elisp/       # Custom processing functions (extending Emacs native features)
└── snippets/    # Code snippet repository (YASnippet templates, multi-language support)
```

### 📝 Supplementary Notes

1. On the first startup, Emacs will automatically download and install required plugins; ensure network connectivity.

2. To modify C/C++ related configurations, check the corresponding LSP configuration files in the `moduls/` directory.

3. Custom code snippets can be directly placed in the corresponding language directory under `snippets/`; restart Emacs to take effect.

---

### ⭐If this configuration helps you, please give the repository a Star to show your support!

### ⭐⭐⭐ Thank you! ⭐⭐⭐
