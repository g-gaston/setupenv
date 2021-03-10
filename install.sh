#/bin/sh

if ! which brew &>/dev/null; then
    echo "Installing brew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Brew already installed"
fi

echo "Brewing brews..."
brew bundle install --file ./Brewfile

PREZTO_INSTALL_DIR="${ZDOTDIR:-$HOME}/.zprezto"
if [ ! -d "$PREZTO_INSTALL_DIR" ]; then
    echo "Installing prezto..."
    git clone --recursive https://github.com/sorin-ionescu/prezto.git $PREZTO_INSTALL_DIR
else
    echo "Prezto already installed"
fi


TMP_INSTALL_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TMP_INSTALL_DIR" ]; then
    echo "Installing tmp..."
    git clone https://github.com/tmux-plugins/tpm $TMP_INSTALL_DIR
    $TMP_INSTALL_DIR/bin/install_plugins
else
    echo "tmp already installed"
fi

DOTFILES_INSTALL_DIR="$HOME/.dotfiles"
if [ ! -d "$DOTFILES_INSTALL_DIR" ]; then
    echo "Installing dotfiles..."
    git clone \
        --separate-git-dir=$DOTFILES_INSTALL_DIR \
        https://github.com/g-gaston/dotfiles.git \
        dotfiles-tmp
    
    rsync --recursive --verbose --exclude '.git' dotfiles-tmp/ $HOME/

    rm -rf dotfiles-tmp
else
    echo "Dotfiles already installed"
fi

echo "Installing vscode extensions..."
cat ./vscode_extensions.txt | xargs -L 1 code --install-extension
