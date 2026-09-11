#!/bin/bash
# ╔═══════════════════════════════════════════════════════════╗
# ║  Arch Linux Dotfiles — Interactive Installer             ║
# ║  Catppuccin Mocha Glassmorphic Setup                     ║
# ╚═══════════════════════════════════════════════════════════╝
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"
REPO_URL="https://github.com/shaheerahmedkhan11/dotfiles-archsetup.git"

# ── Colors ────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAUVE='\033[0;35m'
TEAL='\033[0;36m'
LAVENDER='\033[0;95m'
CRUST='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'

header() {
  clear
  echo -e "${MAUVE}"
  cat << 'EOF'
  ╔═══════════════════════════════════════════════════════════╗
  ║                                                           ║
  ║     ██╗███╗   ██╗██╗   ██╗ ██████╗ ██╗ ██████╗███████╗   ║
  ║     ██║████╗  ██║██║   ██║██╔═══██╗██║██╔════╝██╔════╝   ║
  ║     ██║██╔██╗ ██║██║   ██║██║   ██║██║██║     █████╗     ║
  ║     ██║██║╚██╗██║╚██╗ ██╔╝██║   ██║██║██║     ██╔══╝     ║
  ║     ██║██║ ╚████║ ╚████╔╝ ╚██████╔╝██║╚██████╗███████╗   ║
  ║     ╚═╝╚═╝  ╚═══╝  ╚═══╝   ╚═════╝ ╚═╝ ╚═════╝╚══════╝ ║
  ║                                                           ║
  ║        Catppuccin Mocha · Glassmorphic · Blazing Fast     ║
  ║                                                           ║
  ╚═══════════════════════════════════════════════════════════╝
EOF
  echo -e "${NC}"
}

info()    { echo -e "${BLUE}[INFO]${NC}  $1"; }
ok()      { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
err()     { echo -e "${RED}[ERR]${NC}   $1"; }
step()    { echo -e "\n${MAUVE}${BOLD}═══ $1 ═══${NC}"; }

# ── Helpers ───────────────────────────────────────────────
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    warn "Backing up $dst → ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -sf "$src" "$dst"
  ok "Linked $(basename "$dst")"
}

confirm() {
  local msg="$1" default="${2:-y}"
  local prompt
  if [ "$default" = "y" ]; then
    prompt="${msg} [Y/n]: "
  else
    prompt="${msg} [y/N]: "
  fi
  read -rp "$(echo -e "${TEAL}$prompt${NC}")" choice
  choice="${choice:-$default}"
  [[ "$choice" =~ ^[Yy] ]]
}

select_menu() {
  local title="$1"
  shift
  local options=("$@")
  echo -e "\n${MAUVE}${BOLD}  $title${NC}\n"
  for i in "${!options[@]}"; do
    echo -e "  ${TEAL}$((i+1)))${NC} ${options[$i]}"
  done
  echo ""
  read -rp "$(echo -e "${TEAL}  Select [1-${#options[@]}]: ${NC}")" choice
  echo "$choice"
}

# ══════════════════════════════════════════════════════════
#  PREFLIGHT CHECKS
# ══════════════════════════════════════════════════════════
preflight() {
  step "Preflight Checks"

  # Must be Arch
  if ! grep -qi "arch" /etc/os-release 2>/dev/null; then
    err "This installer is for Arch Linux only."
    exit 1
  fi
  ok "Arch Linux detected"

  # Must be UEFI
  if [ ! -d /sys/firmware/efi ]; then
    err "UEFI system required."
    exit 1
  fi
  ok "UEFI system detected"

  # Check internet
  if ! ping -c1 archlinux.org &>/dev/null; then
    err "No internet connection."
    exit 1
  fi
  ok "Internet connected"

  # Check for AUR helper
  if command -v yay &>/dev/null; then
    AUR_HELPER="yay"
    ok "AUR helper: yay"
  elif command -v paru &>/dev/null; then
    AUR_HELPER="paru"
    ok "AUR helper: paru"
  else
    AUR_HELPER=""
    warn "No AUR helper found (will install yay)"
  fi
}

# ══════════════════════════════════════════════════════════
#  COMPONENT SELECTION
# ══════════════════════════════════════════════════════════
select_components() {
  step "What would you like to install?"

  INSTALL_DESKTOP=false
  INSTALL_TERMINAL=false
  INSTALL_SHELL=false
  INSTALL_DEV=false
  INSTALL_APPS=false
  INSTALL_SYSTEM=false
  INSTALL_ALL=false

  choice=$(select_menu "Installation Scope" \
    "🎯 Everything (Recommended — full setup)" \
    "🖥  Desktop (Hyprland + Waybar + Rofi + Dunst)" \
    "💻 Terminal (Kitty + Alacritty + Neovim + Tmux)" \
    "🐚 Shell (Zsh + Fish + Starship + Oh My Posh)" \
    "⌨  Dev Tools (Git + Lazygit + Bat + Fastfetch)" \
    "📦 Apps (Obsidian + Kvantum + GTK themes)" \
    "⚡ System Tuning (Sysctl + Cpupower + Intel ucode)" \
    "🔧 Custom (pick each component)")

  case "$choice" in
    1) INSTALL_ALL=true ;;
    2) INSTALL_DESKTOP=true ;;
    3) INSTALL_TERMINAL=true ;;
    4) INSTALL_SHELL=true ;;
    5) INSTALL_DEV=true ;;
    6) INSTALL_APPS=true ;;
    7) INSTALL_SYSTEM=true ;;
    8)
      echo ""
      confirm "  Install Desktop (Hyprland/Waybar/Rofi)?" y && INSTALL_DESKTOP=true
      confirm "  Install Terminals (Kitty/Alacritty)?" y && INSTALL_TERMINAL=true
      confirm "  Install Shell (Zsh/Fish/Starship)?" y && INSTALL_SHELL=true
      confirm "  Install Dev Tools (Git/Lazygit/Bat)?" y && INSTALL_DEV=true
      confirm "  Install Apps (Obsidian/Kvantum/GTK)?" y && INSTALL_APPS=true
      confirm "  Apply System Tuning?" y && INSTALL_SYSTEM=true
      ;;
    *) err "Invalid choice"; exit 1 ;;
  esac

  if $INSTALL_ALL; then
    INSTALL_DESKTOP=true
    INSTALL_TERMINAL=true
    INSTALL_SHELL=true
    INSTALL_DEV=true
    INSTALL_APPS=true
    INSTALL_SYSTEM=true
  fi

  echo ""
  info "Components selected:"
  $INSTALL_DESKTOP   && echo -e "  ${GREEN}✓${NC} Desktop"
  $INSTALL_TERMINAL  && echo -e "  ${GREEN}✓${NC} Terminals"
  $INSTALL_SHELL     && echo -e "  ${GREEN}✓${NC} Shell"
  $INSTALL_DEV       && echo -e "  ${GREEN}✓${NC} Dev Tools"
  $INSTALL_APPS      && echo -e "  ${GREEN}✓${NC} Apps"
  $INSTALL_SYSTEM    && echo -e "  ${GREEN}✓${NC} System Tuning"
  echo ""
}

# ══════════════════════════════════════════════════════════
#  PACKAGE INSTALLATION
# ══════════════════════════════════════════════════════════
install_packages() {
  step "Installing Packages"

  # Core packages always needed
  CORE_PKGS=(
    base-devel git curl wget sudo
    networkmanager network-manager-applet
    bash-completion man-db man-pages
  )

  # Desktop
  DESKTOP_PKGS=(
    hyprland hyprlock hyprpaper hypridle hyprpolkitagent
    waybar wofi rofi-wayland dunst
    wl-clipboard cliphist grim slurp
    xdg-desktop-portal-hyprland
    polkit-gnome nm-applet blueman
    pipewire pipewire-pulse pipewire-alsa wireplumber
    brightnessctl upower
    papirus-icon-theme
    qt6ct kvantum
  )

  # Terminal
  TERMINAL_PKGS=(
    kitty alacritty
    neovim
    tmux
  )

  # Shell
  SHELL_PKGS=(
    zsh fish
    starship
    zoxide fzf fd bat eza
    the_silver_searcher
  )

  # Dev
  DEV_PKGS=(
    github-cli delta
    lazygit
    python python-pip
    nodejs npm
    go rust
  )

  # Apps
  APP_PKGS=(
    fastfetch
    obsidian
    qt6-base qt6-wayland
    gtk3 gtk4
    catppuccin-gtk-theme-mocha
  )

  # System
  SYSTEM_PKGS=(
    intel-ucode
    cpupower
    linux-firmware
    btrfs-progs
    zram-generator
    ananicy-cpp
    earlyoom
    irqbalance
    thermald
  )

  # AUR packages
  AUR_PKGS=(
    catppuccin-gtk-theme-mocha
    catppuccin-cursors-mocha
    visual-studio-code-bin
  )

  PACKAGES=()
  $INSTALL_DESKTOP  && PACKAGES+=("${DESKTOP_PKGS[@]}")
  $INSTALL_TERMINAL && PACKAGES+=("${TERMINAL_PKGS[@]}")
  $INSTALL_SHELL    && PACKAGES+=("${SHELL_PKGS[@]}")
  $INSTALL_DEV      && PACKAGES+=("${DEV_PKGS[@]}")
  $INSTALL_APPS     && PACKAGES+=("${APP_PKGS[@]}")
  $INSTALL_SYSTEM   && PACKAGES+=("${SYSTEM_PKGS[@]}")
  PACKAGES+=("${CORE_PKGS[@]}")

  # Deduplicate
  mapfile -t PACKAGES < <(printf '%s\n' "${PACKAGES[@]}" | sort -u)

  info "Installing ${#PACKAGES[@]} packages..."
  sudo pacman -S --needed --noconfirm "${PACKAGES[@]}" || {
    warn "Some packages may have failed, continuing..."
  }

  # AUR packages
  if [ -n "$AUR_HELPER" ] && $INSTALL_APPS; then
    info "Installing AUR packages..."
    $AUR_HELPER -S --needed --noconfirm "${AUR_PKGS[@]}" || true
  elif [ -z "$AUR_HELPER" ] && $INSTALL_APPS; then
    warn "Skipping AUR packages (no AUR helper). Install yay first:"
    echo "  git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si"
  fi

  ok "Packages installed"
}

# ══════════════════════════════════════════════════════════
#  LINK DOTFILES
# ══════════════════════════════════════════════════════════
link_dotfiles() {
  step "Linking Dotfiles"

  # Shell
  if $INSTALL_SHELL || $INSTALL_ALL; then
    link "$DOTFILES_DIR/.zshrc"        "$HOME/.zshrc"
    link "$DOTFILES_DIR/.bashrc"       "$HOME/.bashrc"
    link "$DOTFILES_DIR/.bash_profile" "$HOME/.bash_profile"
    link "$DOTFILES_DIR/.profile"      "$HOME/.profile"
    link "$DOTFILES_DIR/.tmux.conf"    "$HOME/.tmux.conf"
    link "$DOTFILES_DIR/.gitconfig"    "$HOME/.gitconfig"
  fi

  # Desktop
  if $INSTALL_DESKTOP || $INSTALL_ALL; then
    for app in hypr rofi waybar dunst; do
      [ -d "$DOTFILES_DIR/config/$app" ] && link "$DOTFILES_DIR/config/$app" "$CONFIG_DIR/$app"
    done
  fi

  # Terminal
  if $INSTALL_TERMINAL || $INSTALL_ALL; then
    for app in kitty alacritty nvim; do
      [ -d "$DOTFILES_DIR/config/$app" ] && link "$DOTFILES_DIR/config/$app" "$CONFIG_DIR/$app"
    done
  fi

  # Shell tools
  if $INSTALL_SHELL || $INSTALL_ALL; then
    for app in fish lazygit bat fastfetch; do
      [ -d "$DOTFILES_DIR/config/$app" ] && link "$DOTFILES_DIR/config/$app" "$CONFIG_DIR/$app"
    done
    [ -f "$DOTFILES_DIR/config/starship/starship.toml" ] && \
      link "$DOTFILES_DIR/config/starship/starship.toml" "$CONFIG_DIR/starship.toml"
  fi

  # Apps
  if $INSTALL_APPS || $INSTALL_ALL; then
    for app in oh-my-posh obsidian environment.d Kvantum gtk-3.0 gtk-4.0; do
      [ -d "$DOTFILES_DIR/config/$app" ] && link "$DOTFILES_DIR/config/$app" "$CONFIG_DIR/$app"
    done
    [ -f "$DOTFILES_DIR/config/mimeapps.list/mimeapps.list" ] && \
      link "$DOTFILES_DIR/config/mimeapps.list/mimeapps.list" "$CONFIG_DIR/mimeapps.list"
  fi

  ok "Dotfiles linked"
}

# ══════════════════════════════════════════════════════════
#  SYSTEM TUNING
# ══════════════════════════════════════════════════════════
apply_system_tuning() {
  step "Applying System Tuning"

  # Intel microcode
  if ! pacman -Q intel-ucode &>/dev/null; then
    info "Installing intel-ucode..."
    sudo pacman -S --needed --noconfirm intel-ucode
  fi

  # Sysctl
  if [ -f "$DOTFILES_DIR/system/sysctl.d/99-optimize.conf" ]; then
    sudo cp "$DOTFILES_DIR/system/sysctl.d/99-optimize.conf" /etc/sysctl.d/99-optimize.conf
    sudo sysctl --system 2>/dev/null || true
    ok "Sysctl tuning applied (swappiness=180, bbr, etc.)"
  fi

  # Cpupower
  if [ -f "$DOTFILES_DIR/system/cpupower/cpupower-service.conf" ]; then
    sudo cp "$DOTFILES_DIR/system/cpupower/cpupower-service.conf" /etc/default/cpupower-service.conf
    sudo systemctl enable --now cpupower.service 2>/dev/null || true
    ok "CPU governor: performance"
  fi

  # Enable services
  info "Enabling services..."
  for svc in NetworkManager earlyoom ananicy-cpp irqbalance thermald; do
    sudo systemctl enable --now "$svc.service" 2>/dev/null || true
  done

  # Remove conflicting sysctl
  if [ -f /etc/sysctl.d/99-desktop-tuning.conf ]; then
    sudo rm /etc/sysctl.d/99-desktop-tuning.conf
    ok "Removed conflicting 99-desktop-tuning.conf"
  fi

  ok "System tuning applied"
}

# ══════════════════════════════════════════════════════════
#  VISOR BOOTLOADER
# ══════════════════════════════════════════════════════════
configure_bootloader() {
  step "Configuring Bootloader"

  if [ -d /boot/EFI/visor ]; then
    info "Visor bootloader detected"
    if ! grep -q "intel-ucode" /boot/EFI/visor/boot.conf 2>/dev/null; then
      info "Adding intel-ucode to boot entry..."
      sudo sed -i '/^    kernel  = \\vmlinuz-linux$/i\    initrd  = \intel-ucode.img' /boot/EFI/visor/boot.conf
      ok "intel-ucode added to Visor"
    else
      ok "intel-ucode already configured"
    fi
  elif [ -d /boot/loader ]; then
    info "systemd-boot detected"
    if [ ! -f /boot/intel-ucode.img ]; then
      sudo cp /boot/intel-ucode.img /boot/ 2>/dev/null || true
    fi
    # Add to entries
    for entry in /boot/loader/entries/*.conf; do
      if [ -f "$entry" ] && ! grep -q "intel-ucode" "$entry"; then
        sudo sed -i '/^initrd /i initrd /intel-ucode.img' "$entry"
        ok "Added intel-ucode to $(basename "$entry")"
      fi
    done
  else
    warn "No supported bootloader detected. Add intel-ucode manually."
  fi
}

# ══════════════════════════════════════════════════════════
#  ZSH DEFAULT SHELL
# ══════════════════════════════════════════════════════════
setup_shell() {
  step "Shell Setup"

  if $INSTALL_SHELL || $INSTALL_ALL; then
    if [ "$SHELL" != "$(which zsh)" ]; then
      info "Setting zsh as default shell..."
      chsh -s "$(which zsh)"
      ok "Default shell: zsh (restart terminal)"
    else
      ok "zsh is already default shell"
    fi
  fi
}

# ══════════════════════════════════════════════════════════
#  FINISH
# ══════════════════════════════════════════════════════════
finish() {
  clear
  echo -e "${MAUVE}"
  cat << 'EOF'
  ╔═══════════════════════════════════════════════════════════╗
  ║                                                           ║
  ║                   ✅ INSTALLATION COMPLETE                ║
  ║                                                           ║
  ╚═══════════════════════════════════════════════════════════╝
EOF
  echo -e "${NC}"

  echo -e "  ${GREEN}Installed:${NC}"
  $INSTALL_DESKTOP  && echo -e "    ${GREEN}✓${NC} Hyprland + Waybar + Rofi + Dunst"
  $INSTALL_TERMINAL && echo -e "    ${GREEN}✓${NC} Kitty + Alacritty + Neovim + Tmux"
  $INSTALL_SHELL    && echo -e "    ${GREEN}✓${NC} Zsh + Fish + Starship + Oh My Posh"
  $INSTALL_DEV      && echo -e "    ${GREEN}✓${NC} Git + Lazygit + Bat + Fastfetch"
  $INSTALL_APPS     && echo -e "    ${GREEN}✓${NC} Obsidian + Kvantum + GTK themes"
  $INSTALL_SYSTEM   && echo -e "    ${GREEN}✓${NC} Sysctl + Cpupower + Intel ucode"
  echo ""

  echo -e "  ${YELLOW}Next steps:${NC}"
  echo -e "    1. ${BOLD}sudo reboot${NC}  — Apply microcode + sysctl + governor"
  echo -e "    2. Log back in — Hyprland will auto-start via SDDM"
  echo -e "    3. Run ${BOLD}fastfetch${NC} to verify setup"
  echo ""

  echo -e "  ${TEAL}Quick verify:${NC}"
  echo -e "    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
  echo -e "    sysctl vm.swappiness"
  echo -e "    grep intel-ucode /boot/EFI/visor/boot.conf"
  echo ""
}

# ══════════════════════════════════════════════════════════
#  MAIN
# ══════════════════════════════════════════════════════════
main() {
  header
  preflight
  select_components

  echo -e "\n${YELLOW}${BOLD}  Ready to install. This will take a few minutes.${NC}"
  confirm "  Proceed?" y || exit 0

  install_packages
  link_dotfiles
  apply_system_tuning
  configure_bootloader
  setup_shell
  finish
}

main "$@"
