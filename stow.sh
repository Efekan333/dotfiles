cd ~/dotfiles
for p in hypr kitty wofi quickshell; do
  [ -d ~/.config/$p ] && [ ! -L ~/.config/$p ] || { echo "skip $p"; continue; }
  mkdir -p $p/.config
  mv ~/.config/$p $p/.config/
  stow -v $p
done
