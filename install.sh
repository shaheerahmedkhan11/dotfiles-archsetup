#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"

# ── Colors ────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAUVE='\033[0;35m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }

# ── Helpers ───────────────────────────────────────────────
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    warn "Backing up $dst → ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -sf "$src" "$dst"
  ok "Linked $dst"
}

# ══════════════════════════════════════════════════════════
#  1. Install packages
# ══════════════════════════════════════════════════════════
info "Installing official packages..."
if [ -f "$DOTFILES_DIR/packages/pacman-packages.txt" ]; then
  sudo pacman -S --needed - < "$DOTFILES_DIR/packages/pacman-packages.txt"
fi

info "Installing AUR packages..."
if [ -f "$DOTFILES_DIR/packages/aur-packages.txt" ]; then
  if command -v yay &>/dev/null; then
    yay -S --needed - < "$DOTFILES_DIR/packages/aur-packages.txt"
  elif command -v paru &>/dev/null; then
    paru -S --needed - < "$DOTFILES_DIR/packages/aur-packages.txt"
  else
    warn "No AUR helper found. Install yay or paru first."
  fi
fi

# ══════════════════════════════════════════════════════════
#  2. Shell configs
# ══════════════════════════════════════════════════════════
info "Linking shell configs..."
link "$DOTFILES_DIR/.zshrc"        "$HOME/.zshrc"
link "$DOTFILES_DIR/.bashrc"       "$HOME/.bashrc"
link "$DOTFILES_DIR/.bash_profile" "$HOME/.bash_profile"
link "$DOTFILES_DIR/.profile"      "$HOME/.profile"
link "$DOTFILES_DIR/.tmux.conf"    "$HOME/.tmux.conf"
link "$DOTFILES_DIR/.gitconfig"    "$HOME/.gitconfig"

# ══════════════════════════════════════════════════════════
#  3. ~/.config apps
# ══════════════════════════════════════════════════════════
info "Linking ~/.config apps..."
for app in hypr kitty nvim fish dunst alacritty fastfetch oh-my-posh lazygit \
           environment.d bat Kvantum vscode obsidian rofi btop waybar sddm; do
  if [ -d "$DOTFILES_DIR/config/$app" ]; then
    link "$DOTFILES_DIR/config/$app" "$CONFIG_DIR/$app"
  fi
done

# mimeapps.list (file, not dir)
if [ -f "$DOTFILES_DIR/config/mimeapps.list/mimeapps.list" ]; then
  link "$DOTFILES_DIR/config/mimeapps.list/mimeapps.list" "$CONFIG_DIR/mimeapps.list"
fi

# starship.toml (sits in config/starship/ but links to config root)
if [ -f "$DOTFILES_DIR/config/starship/starship.toml" ]; then
  link "$DOTFILES_DIR/config/starship/starship.toml" "$CONFIG_DIR/starship.toml"
fi

# ══════════════════════════════════════════════════════════
#  4. System configs (requires sudo)
# ══════════════════════════════════════════════════════════
info "Applying system configs..."

# Intel microcode
if ! pacman -Q intel-ucode &>/dev/null; then
  info "Installing intel-ucode..."
  sudo pacman -S --needed intel-ucode
fi

# Visor bootloader — add intel-ucode if missing
if [ -f "$DOTFILES_DIR/system/visor/visor-boot.conf" ]; then
  if ! grep -q "intel-ucode" /boot/EFI/visor/boot.conf 2>/dev/null; then
    info "Adding intel-ucode to Visor boot entry..."
    sudo sed -i '/^    kernel  = \\vmlinuz-linux$/i\    initrd  = \intel-ucode.img' /boot/EFI/visor/boot.conf
  fi
fi

# Sysctl tuning
if [ -f "$DOTFILES_DIR/system/sysctl.d/99-optimize.conf" ]; then
  sudo cp "$DOTFILES_DIR/system/sysctl.d/99-optimize.conf" /etc/sysctl.d/99-optimize.conf
  sudo sysctl --system 2>/dev/null
  ok "Sysctl tuning applied"
fi

# Cpupower — set performance governor
if [ -f "$DOTFILES_DIR/system/cpupower/cpupower-service.conf" ]; then
  sudo cp "$DOTFILES_DIR/system/cpupower/cpupower-service.conf" /etc/default/cpupower-service.conf
  sudo systemctl enable --now cpupower.service 2>/dev/null || true
  ok "CPU governor set to performance"
fi

# ══════════════════════════════════════════════════════════
#  5. Scripts
# ══════════════════════════════════════════════════════════
info "Linking scripts..."
for script in "$DOTFILES_DIR/scripts/"*.sh; do
  [ -f "$script" ] && link "$script" "$HOME/$(basename "$script")"
done

# ══════════════════════════════════════════════════════════
#  6. Cyberpunk-hub
# ══════════════════════════════════════════════════════════
if [ ! -d "$HOME/cyberpunk-hub" ]; then
  ln -sf "$DOTFILES_DIR/cyberpunk-hub" "$HOME/cyberpunk-hub"
  ok "Linked ~/cyberpunk-hub"
fi

# ══════════════════════════════════════════════════════════
#  Done
# ══════════════════════════════════════════════════════════
echo ""
echo -e "${MAUVE}════════════════════════════════════════════${NC}"
echo -e "${GREEN}  All dotfiles linked!${NC}"
echo -e "${MAUVE}════════════════════════════════════════════${NC}"
echo ""
echo "  Run: source ~/.zshrc"
echo "  Or reboot for full effect (microcode + sysctl + governor)"
