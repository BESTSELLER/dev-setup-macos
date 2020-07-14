#!/bin/bash 

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"

# Disable mouse acceleration
defaults write .GlobalPreferences com.apple.mouse.scaling -1

# Keyboard settings
# Keyboard --> Key Repeat: Fast (all the way to the right)
# Keyboard --> Delay Until Repeat: Short (all the way to the right)
# Keyboard --> Text --> Untick "Correct spelling automatically"
# Keyboard --> Text --> Untick "Add full stop with double-space"
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 2
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false

# font fix
git clone https://github.com/powerline/fonts.git --depth=1 "$HOME/fonts"
cp -r "$HOME"/fonts/*/*.ttf /Library/Fonts/.
rm -rf "$HOME/fonts"

# Create and set default profile for iTerm2
ITERM_PROFILE_PATH="$HOME/.iterm"
mkdir "$ITERM_PROFILE_PATH"
cp "$HOME/.setup/com.googlecode.iterm2.plist" "$ITERM_PROFILE_PATH/com.googlecode.iterm2.plist"
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$ITERM_PROFILE_PATH"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

# code --list-extensions
cat "$HOME/.setup/vscode.extensions" | xargs -L1 code --install-extension


# Default settings, to make sure that the integrated termnal looks "pretty"
if ! [ -f "$HOME/Library/Application Support/Code/User/settings.json" ]
then
  cp "$HOME/.setup/vscode-settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
fi

# Download iTerm2 shell integration
curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh

export ZSH_PATH="/Users/$(whoami)/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH_PATH/custom"

# kubectl-prompt
git clone https://github.com/superbrothers/zsh-kubectl-prompt.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-kubectl-prompt"

cp "$HOME/.setup/.zshrc" "$HOME/.zshrc"

cp "$HOME/.setup/scripts/go-latest.zsh" "$ZSH_CUSTOM/go-latest.zsh"
cp "$HOME/.setup/scripts/config-clean.zsh" "$ZSH_CUSTOM/config-clean.zsh"

cp "$HOME/.setup/scripts/aks-list.zsh" "$ZSH_CUSTOM/aks-list.zsh"
cp "$HOME/.setup/scripts/aks-login.zsh" "$ZSH_CUSTOM/aks-login.zsh"

cp "$HOME/.setup/scripts/gke-list.zsh" "$ZSH_CUSTOM/gke-list.zsh"
cp "$HOME/.setup/scripts/gke-login.zsh" "$ZSH_CUSTOM/gke-login.zsh"

mkdir -p "$ZSH_PATH/completions"
cp "$HOME/.setup/scripts/_rerun" "$ZSH_PATH/completions/_rerun"
cp "$HOME/.setup/scripts/rerun" "/usr/local/bin/rerun"
chmod +x "/usr/local/bin/rerun"

(
  set -x; cd "$(mktemp -d)" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/download/v0.3.1/krew.{tar.gz,yaml}" &&
  tar zxvf krew.tar.gz &&
  ./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" install \
    --manifest=krew.yaml --archive=krew.tar.gz
)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
kubectl krew install config-cleanup

if [ -z $(git config --global user.email) ]
then
	echo Enter your e-mail:
  read gitEmail
  git config --global user.email "$gitEmail"
  echo Enter your name:
  read gitName
  git config --global user.name "$gitName"
fi

echo -e "\e[0;32m Installation completed! \e[0m"
