#!/bin/bash
# Install script, idk if this will work
ZSH_CUSTOM="$PWD/oh-my-zsh"

PACKAGES="zsh curl neovim \
    build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python-openssl git"

sudo apt install -qq $PACKAGES

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    export RUNZSH="no"
    echo "Fetchig oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install vim-plug
if [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
    echo "Fetching vim-plug"
    curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Install spaceship-prompt
if [ -z "$(ls -A $ZSH_CUSTOM/themes/spaceship-prompt)" ]; then
    echo "Fetching spaceship-prompt"
    git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
    ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
fi

# Install pyenv
if [ ! -d "$HOME/.pyenv" ]; then
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
fi

# Link files
OIFS="$IFS"
IFS=$'\n'
for FILE in $(find . -type f | grep -P "^((?!(install.sh|\.git\b|\./oh-my-zsh/themes/spaceship-prompt)).)*$"); do
    if [[ -f "$HOME/$FILE" && ! -L "$HOME/$FILE" ]]; then
        echo "Moving regular file $FILE"
        mv "$HOME/$FILE" "$HOME/$FILE.old"
    fi
    if [ -L "$HOME/$FILE" ]; then
        echo "$FILE is linked to $(readlink -f "$HOME/$FILE")"
    else
        echo "Linking $FILE"
        mkdir -p "$HOME/$(dirname $FILE)"
        ln -s "$PWD/$FILE" "$HOME/$FILE"
    fi
done
IFS="$OIFS"

git config --global core.excludesFile "$HOME/.gitignore-global"
