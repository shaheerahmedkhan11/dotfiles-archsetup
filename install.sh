#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"

# ── Helpers ───────────────────────────────────────────────
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "⚠ Backing up existing $dst → ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -sf "$src" "$dst"
  echo "✓ Linked $dst → $src"
}

# ── Shell configs ─────────────────────────────────────────
link "$DOTFILES_DIR/.zshrc"        "$HOME/.zshrc"
link "$DOTFILES_DIR/.bashrc"       "$HOME/.bashrc"
link "$DOTFILES_DIR/.tmux.conf"    "$HOME/.tmux.conf"
link "$DOTFILES_DIR/.gitconfig"    "$HOME/.gitconfig"

# ── ~/.config apps ────────────────────────────────────────
for app in hypr kitty nvim fish dunst alacritty fastfetch oh-my-posh lazygit environment.d bat Kvantum vscode obsidian; do
  if [ -d "$DOTFILES_DIR/config/$app" ]; then
    link "$DOTFILES_DIR/config/$app" "$CONFIG_DIR/$app"
  fi
done

# mimeapps.list (file, not dir)
link "$DOTFILES_DIR/config/mimeapps.list/mimeapps.list" "$CONFIG_DIR/mimeapps.list"

# ── Scripts ───────────────────────────────────────────────
link "$DOTFILES_DIR/scripts/optimize-system.sh" "$HOME/optimize-system.sh"
chmod +x "$DOTFILES_DIR/scripts/optimize-system.sh" 2>/dev/null || true

# ── Cyberpunk-hub ─────────────────────────────────────────
if [ ! -d "$HOME/cyberpunk-hub" ]; then
  ln -sf "$DOTFILES_DIR/cyberpunk-hub" "$HOME/cyberpunk-hub"
  echo "✓ Linked ~/cyberpunk-hub"
fi

echo ""
echo "🎉 All dotfiles linked! Restart your shell or run:"
echo "   source ~/.zshrc"
