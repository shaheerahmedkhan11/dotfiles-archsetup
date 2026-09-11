# dotfiles-archsetup

Arch Linux + Hyprland dotfiles — Catppuccin Mocha Glassmorphic theme.

One command to set up a blazing fast Arch system from bare metal.

## Quick Start

```bash
git clone https://github.com/shaheerahmedkhan11/dotfiles-archsetup.git ~/dotfiles-archsetup
cd ~/dotfiles-archsetup
./install.sh
```

The interactive installer lets you pick exactly what to install:
- **Everything** — Full setup in one go
- **Desktop** — Hyprland + Waybar + Rofi + Dunst
- **Terminals** — Kitty + Alacritty + Neovim + Tmux
- **Shell** — Zsh + Fish + Starship + Oh My Posh
- **Dev Tools** — Git + Lazygit + Bat + Fastfetch
- **Apps** — Obsidian + Kvantum + GTK themes
- **System Tuning** — Sysctl + Cpupower + Intel ucode

## What's Included

### Desktop
| App | Config |
|-----|--------|
| Hyprland | `config/hypr/` — WM, lock, wallpaper, scripts |
| Waybar | `config/waybar/` — Glassmorphic top bar with 7 custom scripts |
| Rofi | `config/rofi/` — 9 menu themes (wifi, bluetooth, power, etc.) |
| Dunst | `config/dunst/` — Notifications |

### Terminal
| App | Config |
|-----|--------|
| Kitty | `config/kitty/` — Catppuccin glassmorphic |
| Alacritty | `config/alacritty/` |
| Neovim | `config/nvim/` — LazyVim setup |
| Tmux | `.tmux.conf` — Status bar + keybindings |

### Shell
| App | Config |
|-----|--------|
| Zsh | `.zshrc` |
| Fish | `config/fish/` |
| Starship | `config/starship/` — Catppuccin powerline |
| Oh My Posh | `config/oh-my-posh/` |
| Tools | zoxide, fzf, fd, bat, eza |

### Dev Tools
| App | Config |
|-----|--------|
| Git | `.gitconfig` — Catppuccin delta + aliases |
| Lazygit | `config/lazygit/` |
| Bat | `config/bat/` |
| Fastfetch | `config/fastfetch/` — Catppuccin ASCII |

### System Tuning
| Component | Config |
|-----------|--------|
| Sysctl | `system/sysctl.d/` — swappiness=180, BBR, zram optimized |
| Cpupower | `system/cpupower/` — Performance governor |
| Bootloader | `system/visor/` — Intel microcode in Visor |
| Services | ananicy, earlyoom, irqbalance, thermald |

### Packages
- 135+ official packages
- 9 AUR packages
- Full list in `packages/`

## System Specs Tuned For

- **CPU**: Intel Core i7-8550U (4C/8T, boost to 4.0GHz)
- **RAM**: 32GB DDR4
- **Storage**: 465GB SATA SSD (btrfs, zstd compression)
- **Swap**: zram (15.6GB, zstd)
- **GPU**: Intel UHD Graphics 620
- **Bootloader**: Visor 1.5.4

## Post-Install

```bash
# Reboot for microcode + sysctl + governor
sudo reboot

# Verify
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor  # performance
sysctl vm.swappiness                                         # 180
grep intel-ucode /boot/EFI/visor/boot.conf                   # intel-ucode.img
```

## Cyberpunk Hub

The `cyberpunk-hub/` directory contains an AI Vault Command Center dashboard.
