#!/usr/bin/env bash
# ----------------------------------------------------------------------------
#  One-stop script to set up your environment on a fresh Ubuntu/Debian EC2
#  instance (or any Debian-based system). It:
#    1) Installs necessary packages (zsh, neovim, tmux, etc.).
#    2) Installs Oh My Zsh (unattended) + Powerlevel10k.
#    3) Symlinks your dotfiles from this folder (.vimrc, .zshrc, .tmux, .config).
#    4) Installs vim-plug for Vim & Neovim, then runs PlugInstall.
#    5) Makes zsh the default shell.
# ----------------------------------------------------------------------------
set -e  # Exit if a command fails
set -u  # Treat unset variables as an error

# If this script is in the same folder as your dotfiles, get its directory:
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1) Update & install packages
echo "==> [1/6] Updating and installing base packages..."
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y zsh neovim tmux curl wget git python3 python3-pip nodejs fzf

# 2) Install Oh My Zsh & Powerlevel10k
echo "==> [2/6] Installing Oh My Zsh (unattended) and Powerlevel10k..."
export RUNZSH=no
sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" || true

# 3) Symlink your dotfiles
echo "==> [3/6] Symlinking dotfiles from $DOTFILES_DIR to your home (~)..."

# .vimrc
ln -sfn "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"

# .zshrc
ln -sfn "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# .tmux (if you want the entire folder in ~)
# If you actually keep a .tmux.conf, adjust as needed
ln -sfn "$DOTFILES_DIR/.tmux" "$HOME/.tmux"

# For .config subfolders (like nvim, etc.)
if [ -d "$DOTFILES_DIR/.config" ]; then
  mkdir -p "$HOME/.config"
  for item in "$DOTFILES_DIR/.config/"*; do
    base_item="$(basename "$item")"
    ln -sfn "$item" "$HOME/.config/$base_item"
  done
fi

# 4) Install vim-plug for Vim & Neovim
echo "==> [4/6] Installing vim-plug..."
curl -sfLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

curl -sfLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# 5) Run PlugInstall for Vim & Neovim
echo "==> [5/6] Running :PlugInstall for Vim & Neovim..."
vim +PlugInstall +qall || true
nvim +PlugInstall +qall || true

# 6) Make zsh default shell
echo "==> [6/6] Changing default shell to zsh..."
chsh -s "$(command -v zsh)" || true

echo
echo "============================================"
echo " All done! Re-open your terminal or run:"
echo "    exec zsh"
echo " to start using your new environment."
echo "============================================"
