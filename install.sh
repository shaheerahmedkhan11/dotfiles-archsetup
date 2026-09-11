#!/bin/bash
# ╔═══════════════════════════════════════════════════════════╗
# ║  Arch Linux Dotfiles — Intelligent Installer             ║
# ║  Catppuccin Mocha Glassmorphic Setup                     ║
# ║  Auto-detects hardware · Adapts theme · Blazing fast     ║
# ╚═══════════════════════════════════════════════════════════╝
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"

# ── Colors ────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAUVE='\033[0;35m'
TEAL='\033[0;36m'
LAVENDER='\033[0;95m'
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
header2() { echo -e "\n${TEAL}${BOLD}─── $1 ───${NC}"; }

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

# ══════════════════════════════════════════════════════════
#  HARDWARE DETECTION
# ══════════════════════════════════════════════════════════
detect_hardware() {
  step "Scanning Hardware"

  # CPU
  CPU_MODEL=$(lscpu | grep "Model name" | sed 's/.*:\s*//' | head -1)
  CPU_CORES=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
  CPU_VENDOR=$(lscpu | grep "Vendor ID" | awk '{print $3}')
  ok "CPU: $CPU_MODEL ($CPU_CORES cores)"

  # RAM
  RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  RAM_GB=$((RAM_KB / 1024 / 1024))
  ok "RAM: ${RAM_GB}GB"

  # GPU
  GPU_INFO=$(lspci | grep -iE "VGA|3D|Display" | head -1)
  if echo "$GPU_INFO" | grep -qi "intel"; then
    GPU_TYPE="intel"
    GPU_NAME=$(echo "$GPU_INFO" | sed 's/.*: //')
  elif echo "$GPU_INFO" | grep -qi "nvidia"; then
    GPU_TYPE="nvidia"
    GPU_NAME=$(echo "$GPU_INFO" | sed 's/.*: //')
  elif echo "$GPU_INFO" | grep -qi "amd\|radeon"; then
    GPU_TYPE="amd"
    GPU_NAME=$(echo "$GPU_INFO" | sed 's/.*: //')
  else
    GPU_TYPE="unknown"
    GPU_NAME=$(echo "$GPU_INFO" | sed 's/.*: //')
  fi
  ok "GPU: $GPU_NAME ($GPU_TYPE)"

  # Storage
  STORAGE_TYPE="unknown"
  STORAGE_SIZE="unknown"
  if [ -f /sys/block/sda/queue/rotational ]; then
    ROT=$(cat /sys/block/sda/queue/rotational 2>/dev/null || echo "0")
    if [ "$ROT" = "0" ]; then
      STORAGE_TYPE="SSD"
    else
      STORAGE_TYPE="HDD"
    fi
  elif [ -f /sys/block/nvme0n1/queue/rotational ]; then
    STORAGE_TYPE="NVMe"
  fi
  STORAGE_SIZE=$(lsblk -dno SIZE /dev/sda 2>/dev/null | head -1 | xargs || echo "unknown")
  ok "Storage: $STORAGE_TYPE ($STORAGE_SIZE)"

  # Screen Resolution
  SCREEN_RES="1920x1080"
  if command -v xrandr &>/dev/null; then
    SCREEN_RES=$(xrandr 2>/dev/null | grep " connected" | grep -oP '\d+x\d+' | head -1 || echo "1920x1080")
  elif [ -d /sys/class/drm ]; then
    for conn in /sys/class/drm/card*-*; do
      if [ -f "$conn/status" ] && grep -q "connected" "$conn/status" 2>/dev/null; then
        if [ -f "$conn/modes" ]; then
          SCREEN_RES=$(head -1 "$conn/modes" 2>/dev/null | xargs || echo "1920x1080")
          break
        fi
      fi
    done
  fi
  ok "Resolution: $SCREEN_RES"

  # Laptop Detection
  IS_LAPTOP=false
  if [ -d /sys/class/power_supply/BAT0 ] || [ -d /sys/class/power_supply/BAT1 ]; then
    IS_LAPTOP=true
    ok "Form factor: Laptop (battery detected)"
  elif grep -qi "laptop\|notebook" /sys/class/dmi/id/product-name 2>/dev/null; then
    IS_LAPTOP=true
    ok "Form factor: Laptop (DMI match)"
  else
    ok "Form factor: Desktop"
  fi

  # Bootloader
  BOOTLOADER="unknown"
  if [ -d /boot/EFI/visor ]; then
    BOOTLOADER="visor"
  elif [ -d /boot/loader ]; then
    BOOTLOADER="systemd-boot"
  elif [ -f /boot/grub/grub.cfg ]; then
    BOOTLOADER="grub"
  fi
  ok "Bootloader: $BOOTLOADER"

  # Internet
  NET_INTERFACE=$(ip route show default 2>/dev/null | awk '/dev/{print $5}' | head -1 || echo "unknown")
  ok "Network: $NET_INTERFACE"

  echo ""
}

# ══════════════════════════════════════════════════════════
#  INTELLIGENT CONFIGURATION
# ══════════════════════════════════════════════════════════
configure_intelligently() {
  step "Intelligent Configuration"

  # ── Opacity based on RAM (more RAM = more blur allowed) ──
  if [ "$RAM_GB" -ge 32 ]; then
    OPACITY_ACTIVE="0.98"
    OPACITY_INACTIVE="0.95"
    BLUR_SIZE="14"
    BLUR_PASSES="5"
    BLUR_BRIGHTNESS="1.35"
  elif [ "$RAM_GB" -ge 16 ]; then
    OPACITY_ACTIVE="0.96"
    OPACITY_INACTIVE="0.92"
    BLUR_SIZE="12"
    BLUR_PASSES="4"
    BLUR_BRIGHTNESS="1.25"
  elif [ "$RAM_GB" -ge 8 ]; then
    OPACITY_ACTIVE="0.94"
    OPACITY_INACTIVE="0.88"
    BLUR_SIZE="10"
    BLUR_PASSES="3"
    BLUR_BRIGHTNESS="1.15"
  else
    OPACITY_ACTIVE="0.92"
    OPACITY_INACTIVE="0.85"
    BLUR_SIZE="8"
    BLUR_PASSES="2"
    BLUR_BRIGHTNESS="1.0"
  fi
  ok "Opacity: active=$OPACITY_ACTIVE inactive=$OPACITY_INACTIVE (based on ${RAM_GB}GB RAM)"

  # ── Shadows based on GPU ──
  case "$GPU_TYPE" in
    nvidia)
      SHADOW_ENABLED="true"
      SHADOW_RANGE="10"
      SHADOW_BLUR="true"
      ok "Shadows: Enhanced (dedicated GPU)"
      ;;
    amd)
      SHADOW_ENABLED="true"
      SHADOW_RANGE="8"
      SHADOW_BLUR="true"
      ok "Shadows: Standard (AMD GPU)"
      ;;
    intel)
      SHADOW_ENABLED="true"
      SHADOW_RANGE="6"
      SHADOW_BLUR="false"
      ok "Shadows: Lightweight (integrated GPU)"
      ;;
    *)
      SHADOW_ENABLED="true"
      SHADOW_RANGE="6"
      SHADOW_BLUR="false"
      ok "Shadows: Lightweight (unknown GPU)"
      ;;
  esac

  # ── Gaps based on screen resolution ──
  RES_X=$(echo "$SCREEN_RES" | cut -d'x' -f1)
  if [ "${RES_X:-1920}" -ge 2560 ]; then
    GAPS_IN="8"
    GAPS_OUT="14"
    ok "Gaps: Large (HiDPI/ultrawide)"
  elif [ "${RES_X:-1920}" -ge 1920 ]; then
    GAPS_IN="6"
    GAPS_OUT="10"
    ok "Gaps: Standard (1080p+)"
  else
    GAPS_IN="4"
    GAPS_OUT="8"
    ok "Gaps: Compact (low resolution)"
  fi

  # ── Swappiness based on storage type ──
  case "$STORAGE_TYPE" in
    NVMe)
      SWAPPINESS="120"
      ok "Swappiness: $SWAPPINESS (NVMe fast)"
      ;;
    SSD)
      SWAPPINESS="180"
      ok "Swappiness: $SWAPPINESS (SATA SSD, zram preferred)"
      ;;
    HDD)
      SWAPPINESS="10"
      ok "Swappiness: $SWAPPINESS (HDD, avoid swap)"
      ;;
    *)
      SWAPPINESS="100"
      ok "Swappiness: $SWAPPINESS (default)"
      ;;
  esac

  # ── Laptop-specific settings ──
  if $IS_LAPTOP; then
    LAPTOP_OPTIMIZATIONS=true
    ok "Laptop mode: battery optimization, touchpad, brightness keys enabled"
  else
    LAPTOP_OPTIMIZATIONS=false
    ok "Desktop mode: performance-first, no battery management"
  fi

  # ── Microcode ──
  MICROCODE="intel-ucode"
  if echo "$CPU_VENDOR" | grep -qi "amd"; then
    MICROCODE="amd-ucode"
  fi
  ok "Microcode: $MICROCODE"
}

# ══════════════════════════════════════════════════════════
#  PREFLIGHT CHECKS
# ══════════════════════════════════════════════════════════
preflight() {
  step "Preflight Checks"

  if ! grep -qi "arch" /etc/os-release 2>/dev/null; then
    err "This installer is for Arch Linux only."
    exit 1
  fi
  ok "Arch Linux detected"

  if [ ! -d /sys/firmware/efi ]; then
    err "UEFI system required."
    exit 1
  fi
  ok "UEFI system detected"

  if ! ping -c1 archlinux.org &>/dev/null; then
    err "No internet connection."
    exit 1
  fi
  ok "Internet connected"

  if command -v yay &>/dev/null; then
    AUR_HELPER="yay"
  elif command -v paru &>/dev/null; then
    AUR_HELPER="paru"
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
    "⚡ System Tuning (Sysctl + Cpupower + Microcode)" \
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
#  PACKAGE INSTALLATION
# ══════════════════════════════════════════════════════════
install_packages() {
  step "Installing Packages"

  CORE_PKGS=(
    base-devel git curl wget sudo
    networkmanager network-manager-applet
    bash-completion man-db man-pages
  )

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

  TERMINAL_PKGS=(
    kitty alacritty neovim tmux
  )

  SHELL_PKGS=(
    zsh fish starship
    zoxide fzf fd bat eza
    the_silver_searcher
  )

  DEV_PKGS=(
    github-cli delta lazygit
    python python-pip nodejs npm
  )

  APP_PKGS=(
    fastfetch obsidian
    qt6-base qt6-wayland gtk3 gtk4
  )

  SYSTEM_PKGS=()
  if [ "$MICROCODE" = "intel-ucode" ]; then
    SYSTEM_PKGS+=(intel-ucode)
  else
    SYSTEM_PKGS+=(amd-ucode)
  fi
  SYSTEM_PKGS+=(cpupower linux-firmware btrfs-progs zram-generator ananicy-cpp earlyoom irqbalance thermald)

  # Laptop-specific packages
  if $IS_LAPTOP; then
    SYSTEM_PKGS+=(tlp tlp-rdw powertop)
  fi

  # GPU-specific packages
  case "$GPU_TYPE" in
    nvidia)
      DESKTOP_PKGS+=(nvidia-utils nvidia-settings)
      ;;
    amd)
      DESKTOP_PKGS+=(mesa vulkan-radeon libva-mesa-driver)
      ;;
    intel)
      DESKTOP_PKGS+=(mesa intel-media-driver libva-intel-driver)
      ;;
  esac

  AUR_PKGS=(
    catppuccin-gtk-theme-mocha
    catppuccin-cursors-mocha
  )

  PACKAGES=()
  $INSTALL_DESKTOP  && PACKAGES+=("${DESKTOP_PKGS[@]}")
  $INSTALL_TERMINAL && PACKAGES+=("${TERMINAL_PKGS[@]}")
  $INSTALL_SHELL    && PACKAGES+=("${SHELL_PKGS[@]}")
  $INSTALL_DEV      && PACKAGES+=("${DEV_PKGS[@]}")
  $INSTALL_APPS     && PACKAGES+=("${APP_PKGS[@]}")
  $INSTALL_SYSTEM   && PACKAGES+=("${SYSTEM_PKGS[@]}")
  PACKAGES+=("${CORE_PKGS[@]}")

  mapfile -t PACKAGES < <(printf '%s\n' "${PACKAGES[@]}" | sort -u)

  info "Installing ${#PACKAGES[@]} packages..."
  sudo pacman -S --needed --noconfirm "${PACKAGES[@]}" || {
    warn "Some packages may have failed, continuing..."
  }

  if [ -n "$AUR_HELPER" ] && $INSTALL_APPS; then
    info "Installing AUR packages..."
    $AUR_HELPER -S --needed --noconfirm "${AUR_PKGS[@]}" || true
  elif [ -z "$AUR_HELPER" ] && $INSTALL_APPS; then
    warn "Skipping AUR packages (no AUR helper)."
  fi

  ok "Packages installed"
}

# ══════════════════════════════════════════════════════════
#  APPLY INTELLIGENT CONFIG
# ══════════════════════════════════════════════════════════
apply_intelligent_config() {
  step "Applying Hardware-Optimized Config"

  # ── Hyprland ──
  if $INSTALL_DESKTOP || $INSTALL_ALL; then
    header2 "Hyprland"

    sed -i \
      -e "s/active_opacity    = [0-9.]*/active_opacity    = $OPACITY_ACTIVE/" \
      -e "s/inactive_opacity  = [0-9.]*/inactive_opacity  = $OPACITY_INACTIVE/" \
      -e "s/size           = [0-9]*/size           = $BLUR_SIZE/" \
      -e "s/passes         = [0-9]*/passes         = $BLUR_PASSES/" \
      -e "s/brightness     = [0-9.]*/brightness     = $BLUR_BRIGHTNESS/" \
      -e "s/gaps_in              = [0-9]*/gaps_in              = $GAPS_IN/" \
      -e "s/gaps_out             = [0-9]*/gaps_out             = $GAPS_OUT/" \
      -e "s/enabled       = true,/enabled       = $SHADOW_ENABLED,/" \
      -e "s/range         = [0-9]*/range         = $SHADOW_RANGE/" \
      "$CONFIG_DIR/hypr/hyprland.lua" 2>/dev/null || true

    ok "Hyprland: opacity=$OPACITY_ACTIVE, blur=${BLUR_SIZE}px/${BLUR_PASSES}pass, gaps=${GAPS_IN}/${GAPS_OUT}"

    # Laptop touchpad
    if $IS_LAPTOP; then
      sed -i 's/natural_scroll = false,/natural_scroll = true,/' "$CONFIG_DIR/hypr/hyprland.lua" 2>/dev/null || true
      ok "Hyprland: natural scroll enabled (laptop)"
    fi
  fi

  # ── Sysctl ──
  if $INSTALL_SYSTEM || $INSTALL_ALL; then
    header2 "Sysctl"

    cat > /tmp/99-optimize.conf << SYSEOF
# Hardware-tuned — auto-generated by installer
# CPU: $CPU_MODEL | RAM: ${RAM_GB}GB | Storage: $STORAGE_TYPE
vm.swappiness = $SWAPPINESS
vm.vfs_cache_pressure = 50
vm.page-cluster = 0
vm.watermark_boost_factor = 1
vm.watermark_scale_factor = 125
vm.dirty_background_ratio = 5
vm.dirty_ratio = 15
vm.dirty_writeback_centisecs = 500
vm.min_free_kbytes = $(( RAM_KB / 128 ))
vm.zone_reclaim_mode = 0
net.core.somaxconn = 4096
fs.inotify.max_user_watches = 1048576
SYSEOF

    sudo cp /tmp/99-optimize.conf /etc/sysctl.d/99-optimize.conf
    sudo sysctl --system 2>/dev/null || true
    ok "Sysctl: swappiness=$SWAPPINESS, min_free_kbytes=$(( RAM_KB / 128 ))"

    # Cpupower
    if [ "$CPU_VENDOR" = "GenuineIntel" ]; then
      cat > /tmp/cpupower-service.conf << 'CPEOF'
GOVERNOR="performance"
CPEOF
    else
      cat > /tmp/cpupower-service.conf << 'CPEOF'
GOVERNOR="performance"
CPEOF
    fi
    sudo cp /tmp/cpupower-service.conf /etc/default/cpupower-service.conf
    sudo systemctl enable --now cpupower.service 2>/dev/null || true
    ok "CPU governor: performance"

    # Enable services
    info "Enabling services..."
    for svc in NetworkManager earlyoom ananicy-cpp irqbalance thermald; do
      sudo systemctl enable --now "$svc.service" 2>/dev/null || true
    done

    # Laptop services
    if $IS_LAPTOP; then
      sudo systemctl enable --now tlp.service 2>/dev/null || true
      sudo systemctl mask sleep.target suspend.target hibernate.target 2>/dev/null || true
      ok "TLP enabled for battery optimization"
    fi

    # Remove conflicting sysctl
    if [ -f /etc/sysctl.d/99-desktop-tuning.conf ]; then
      sudo rm /etc/sysctl.d/99-desktop-tuning.conf
    fi
  fi
}

# ══════════════════════════════════════════════════════════
#  LINK DOTFILES
# ══════════════════════════════════════════════════════════
link_dotfiles() {
  step "Linking Dotfiles"

  if $INSTALL_SHELL || $INSTALL_ALL; then
    link "$DOTFILES_DIR/.zshrc"        "$HOME/.zshrc"
    link "$DOTFILES_DIR/.bashrc"       "$HOME/.bashrc"
    link "$DOTFILES_DIR/.bash_profile" "$HOME/.bash_profile"
    link "$DOTFILES_DIR/.profile"      "$HOME/.profile"
    link "$DOTFILES_DIR/.tmux.conf"    "$HOME/.tmux.conf"
    link "$DOTFILES_DIR/.gitconfig"    "$HOME/.gitconfig"
  fi

  if $INSTALL_DESKTOP || $INSTALL_ALL; then
    for app in hypr rofi waybar dunst; do
      [ -d "$DOTFILES_DIR/config/$app" ] && link "$DOTFILES_DIR/config/$app" "$CONFIG_DIR/$app"
    done
  fi

  if $INSTALL_TERMINAL || $INSTALL_ALL; then
    for app in kitty alacritty nvim; do
      [ -d "$DOTFILES_DIR/config/$app" ] && link "$DOTFILES_DIR/config/$app" "$CONFIG_DIR/$app"
    done
  fi

  if $INSTALL_SHELL || $INSTALL_ALL; then
    for app in fish lazygit bat fastfetch; do
      [ -d "$DOTFILES_DIR/config/$app" ] && link "$DOTFILES_DIR/config/$app" "$CONFIG_DIR/$app"
    done
    [ -f "$DOTFILES_DIR/config/starship/starship.toml" ] && \
      link "$DOTFILES_DIR/config/starship/starship.toml" "$CONFIG_DIR/starship.toml"
  fi

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
#  BOOTLOADER
# ══════════════════════════════════════════════════════════
configure_bootloader() {
  step "Configuring Bootloader"

  case "$BOOTLOADER" in
    visor)
      if ! grep -q "$MICROCODE" /boot/EFI/visor/boot.conf 2>/dev/null; then
        sudo sed -i "/^    kernel  = \\\\vmlinuz-linux$/i\\    initrd  = \\\\${MICROCODE}.img" /boot/EFI/visor/boot.conf
        ok "Added $MICROCODE to Visor"
      else
        ok "$MICROCODE already in Visor"
      fi
      ;;
    systemd-boot)
      for entry in /boot/loader/entries/*.conf; do
        if [ -f "$entry" ] && ! grep -q "$MICROCODE" "$entry"; then
          sudo sed -i "/^initrd /i initrd /${MICROCODE}.img" "$entry"
          ok "Added $MICROCODE to $(basename "$entry")"
        fi
      done
      ;;
    grub)
      if ! grep -q "$MICROCODE" /etc/default/grub 2>/dev/null; then
        sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"initrd=\\/${MICROCODE}.img /" /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg
        ok "Added $MICROCODE to GRUB"
      fi
      ;;
    *)
      warn "No supported bootloader detected. Add $MICROCODE manually."
      ;;
  esac
}

# ══════════════════════════════════════════════════════════
#  SHELL
# ══════════════════════════════════════════════════════════
setup_shell() {
  step "Shell Setup"

  if $INSTALL_SHELL || $INSTALL_ALL; then
    if [ "$SHELL" != "$(which zsh)" ]; then
      chsh -s "$(which zsh)"
      ok "Default shell: zsh"
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

  echo -e "  ${BOLD}Detected System:${NC}"
  echo -e "    CPU:     $CPU_MODEL"
  echo -e "    GPU:     $GPU_NAME"
  echo -e "    RAM:     ${RAM_GB}GB"
  echo -e "    Storage: $STORAGE_TYPE"
  echo -e "    Screen:  $SCREEN_RES"
  echo -e "    Type:    $(if $IS_LAPTOP; then echo 'Laptop'; else echo 'Desktop'; fi)"
  echo ""

  echo -e "  ${GREEN}Applied Settings:${NC}"
  echo -e "    Opacity:   $OPACITY_ACTIVE / $OPACITY_INACTIVE"
  echo -e "    Blur:      ${BLUR_SIZE}px, ${BLUR_PASSES} passes"
  echo -e "    Gaps:      ${GAPS_IN}in / ${GAPS_OUT}out"
  echo -e "    Swappiness: $SWAPPINESS"
  echo -e "    Microcode: $MICROCODE"
  $IS_LAPTOP && echo -e "    Battery:   TLP enabled"
  echo ""

  echo -e "  ${YELLOW}Next steps:${NC}"
  echo -e "    1. ${BOLD}sudo reboot${NC}"
  echo -e "    2. Log back in"
  echo -e "    3. Run ${BOLD}fastfetch${NC} to verify"
  echo ""
}

# ══════════════════════════════════════════════════════════
#  MAIN
# ══════════════════════════════════════════════════════════
main() {
  header
  preflight
  detect_hardware
  configure_intelligently
  select_components

  echo -e "\n${YELLOW}${BOLD}  Ready to install. This will take a few minutes.${NC}"
  confirm "  Proceed?" y || exit 0

  install_packages
  link_dotfiles
  apply_intelligent_config
  configure_bootloader
  setup_shell
  finish
}

main "$@"
