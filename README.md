# dotfiles-archsetup

Arch Linux + Hyprland dotfiles — Catppuccin Mocha Glassmorphic theme.

Blazing fast i7-8550U / 32GB RAM / SATA SSD setup with full system tuning.

## What's Included

### Desktop
| App | Config |
|-----|--------|
| Hyprland | `config/hypr/` — WM, lock, wallpaper, scripts |
| Waybar | `config/waybar/` — Glassmorphic top bar with custom scripts |
| Rofi | `config/rofi/` — App launcher, power menu, wifi, bluetooth, etc. |
| Dunst | `config/dunst/` — Notifications |
| Kitty | `config/kitty/` — Terminal |
| Alacritty | `config/alacritty/` — Terminal |

### Dev Tools
| App | Config |
|-----|--------|
| Neovim | `config/nvim/` — LazyVim setup |
| Tmux | `.tmux.conf` — Status bar + keybindings |
| Lazygit | `config/lazygit/` |
| Git | `.gitconfig` — Catppuccin delta theme + aliases |
| Bat | `config/bat/` |

### Shell
| App | Config |
|-----|--------|
| Zsh | `.zshrc` |
| Bash | `.bashrc` |
| Fish | `config/fish/` |
| Starship | `config/starship/` — Catppuccin powerline prompt |
| Oh My Posh | `config/oh-my-posh/` |

### System
| App | Config |
|-----|--------|
| Sysctl | `system/sysctl.d/` — VM + network tuning |
| Cpupower | `system/cpupower/` — Performance governor |
| Visor | `system/visor/` — Bootloader config |
| Environment | `config/environment.d/` — GTK/Qt/Hypr vars |

### Apps
| App | Config |
|-----|--------|
| Fastfetch | `config/fastfetch/` — Catppuccin system info |
| Kvantum | `config/Kvantum/` — Qt theme |
| GTK | `config/gtk-3.0/`, `config/gtk-4.0/` |
| Obsidian | `config/obsidian/` |

## System Specs Tuned For

- **CPU**: Intel Core i7-8550U (4C/8T, boost to 4.0GHz)
- **RAM**: 32GB DDR4
- **Storage**: 465GB SATA SSD (btrfs, zstd compression)
- **Swap**: zram (15.6GB, zstd)
- **GPU**: Intel UHD Graphics 620
- **Bootloader**: Visor 1.5.4

## Install

```bash
git clone git@github.com:shaheerahmedkhan11/dotfiles-archsetup.git ~/dotfiles-archsetup
cd ~/dotfiles-archsetup
chmod +x install.sh
./install.sh
```

The installer:
1. Installs all packages from `packages/`
2. Links all dotfiles (backs up existing configs)
3. Applies system tuning (sysctl, cpupower, intel-ucode)
4. Configures Visor bootloader

Reboot after install for full effect.

## Manual Steps

After install, verify these:

```bash
# Check CPU governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
# Should show: performance

# Check sysctl
sysctl vm.swappiness
# Should show: 180

# Check intel-ucode in Visor
grep intel-ucode /boot/EFI/visor/boot.conf
```

## Quick Theme Switch

All configs use Catppuccin Mocha. To switch colorscheme:
1. Change colors in `config/kitty/kitty.conf`, `config/alacritty/alacritty.toml`
2. Update `config/waybar/style.css` (Catppuccin color variables at top)
3. Update `config/rofi/config.rasi` color definitions
4. Update `config/dunst/dunstrc` frame_color
5. Update `config/environment.d/catppuccin.conf` GTK_THEME

## Cyberpunk Hub

The `cyberpunk-hub/` directory contains an AI Vault Command Center dashboard.
