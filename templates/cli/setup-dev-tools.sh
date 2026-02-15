#!/bin/bash
# Helper to install development tools on Linux/macOS
# Installs: just, direnv, tmux

set -e

echo "Installing dev tools..."

install_just() {
    if ! command -v just &> /dev/null; then
        echo "Installing just..."
        curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin
    else
        echo "just is already installed."
    fi
}

install_bun() {
    if ! command -v bun &> /dev/null; then
        echo "Installing bun..."
        curl -fsSL https://bun.sh/install | bash
        # Source bun config for current session if possible
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
    else
        echo "bun is already installed."
    fi
}

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu
        echo "Detected Debian/Ubuntu"
        sudo apt-get update
        sudo apt-get install -y tmux direnv
        install_just
        install_bun
        
    elif command -v dnf &> /dev/null; then
        # Fedora
        echo "Detected Fedora"
        sudo dnf install -y just direnv tmux
        install_bun
        
    elif command -v pacman &> /dev/null; then
        # Arch
        echo "Detected Arch Linux"
        sudo pacman -S --noconfirm just direnv tmux
        install_bun
        
    elif command -v zypper &> /dev/null; then
        # openSUSE
        echo "Detected openSUSE"
        sudo zypper install -y just direnv tmux
        install_bun
    else
        echo "Unsupported Linux distribution. Please install just, direnv, and tmux manually."
        exit 1
    fi
    
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if command -v brew &> /dev/null; then
        echo "Detected macOS"
        brew install just direnv tmux
        install_bun
    else
        echo "Homebrew not found. Please install Homebrew first."
        exit 1
    fi
else
    echo "Unsupported OS: $OSTYPE"
    echo "Please install just, direnv, and tmux manually."
    exit 1
fi

echo ""
echo "Installation complete!"
echo "Run 'direnv allow' to enable automatic environment loading."
