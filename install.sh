# Create a symlink to the .zshrc file on github so therefore it syncs online :D

ln -s "$PWD/.zshrc" "$HOME/.zshrc" 

# Clone my neovim repo
git clone https://github.com/irakin30/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim 


