# dotfiles-archsetup

Arch Linux + Hyprland dotfiles — Catppuccin Cyberpunk Glassmorphic theme.

## What's Included

| App | Config |
|-----|--------|
| Hyprland | `config/hypr/` — WM, lock, wallpaper |
| Kitty | `config/kitty/` |
| Neovim | `config/nvim/` — LazyVim setup |
| Fish | `config/fish/` |
| Dunst | `config/dunst/` |
| Alacritty | `config/alacritty/` |
| Fastfetch | `config/fastfetch/` |
| Oh My Posh | `config/oh-my-posh/` — Catppuccin themes |
| Lazygit | `config/lazygit/` |
| VSCode/OSS | `config/vscode/` — settings, keybindings, extensions |
| Obsidian | `config/obsidian/` |
| Bat | `config/bat/` |
| Kvantum | `config/Kvantum/` |
| Environment | `config/environment.d/` |
| Tmux | `.tmux.conf` |
| Zsh | `.zshrc` |
| Bash | `.bashrc` |
| Git | `.gitconfig` (Catppuccin delta theme) |
| Scripts | `scripts/optimize-system.sh` |
| Cyberpunk Hub | `cyberpunk-hub/` — AI Vault Command Center |

## Install

```bash
git clone git@github.com:shaheerahmedkhan11/dotfiles-archsetup.git ~/dotfiles-archsetup
cd ~/dotfiles-archsetup
chmod +x install.sh
./install.sh
```

The installer backs up existing configs before linking.
