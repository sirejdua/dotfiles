#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! command -v chezmoi >/dev/null 2>&1; then
    echo "Install chezmoi first: https://www.chezmoi.io/install/" >&2
    exit 1
fi

if [[ "$(uname -s)" != "Linux" ]]; then
    echo "This repository's managed configs are currently Linux-only."
    exit 0
fi

echo "=== Dotfiles Install ==="
echo "Previewing changes..."
chezmoi --source "$DOTFILES_DIR" diff

read -rp "Apply these configs? [y/N] " apply_answer
if [[ ! "$apply_answer" =~ ^[Yy]$ ]]; then
    echo "No changes applied."
    exit 0
fi

chezmoi --source "$DOTFILES_DIR" apply --verbose

# --- Git identity ---
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
    echo ""
    echo "Setting up git identity (~/.gitconfig.local)..."
    read -rp "  Name: " git_name
    read -rp "  Email: " git_email
    read -rp "  GPG signing key (blank to skip): " git_signingkey

    {
        echo "[user]"
        echo "	name = $git_name"
        echo "	email = $git_email"
        if [[ -n "$git_signingkey" ]]; then
            echo "	signingkey = $git_signingkey"
            echo "[commit]"
            echo "	gpgsign = true"
        fi
    } > "$HOME/.gitconfig.local"
    echo "  [created] ~/.gitconfig.local"
else
    echo ""
    echo "[skip] ~/.gitconfig.local already exists"
fi

# --- Tools ---
echo ""
read -rp "Install tools? (uv, gh) [y/N] " tools
if [[ "$tools" =~ ^[Yy]$ ]]; then
    if ! command -v uv &>/dev/null; then
        echo "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    else
        echo "  [skip] uv $(uv --version 2>/dev/null || echo '(installed)')"
    fi

    if ! command -v gh &>/dev/null; then
        echo "Installing gh..."
        (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
            && sudo mkdir -p -m 755 /etc/apt/keyrings \
            && out=$(mktemp) \
            && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
            && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
            && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
            && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
                | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
            && sudo apt update && sudo apt install gh -y
    else
        echo "  [skip] gh $(gh --version 2>/dev/null | head -1 || echo '(installed)')"
    fi
fi

# --- Summary ---
echo ""
echo "Done. Machine-specific config goes in:"
echo "  ~/.bashrc.local    (sourced at end of .bashrc)"
echo "  ~/.gitconfig.local (included by .gitconfig)"
echo ""
echo "Restart your shell or run: source ~/.bashrc"
