#!/bin/bash 

# exit when any command fails
set -e

# Check if we are admin before continuing
sudo -l &> /dev/null
if [ $? -ne 0 ]
then
  echo -e "\e[0;31mYou are not admin \!\e[0m"
  echo -e "\e[0;31mPlease become admin and then re-run this script.\e[0m"
fi

# Make sure Command Line Tools for Xcode is installed before installing Homebrew
if ! xcode-select -p &> /dev/null ; then
  echo -e "\e[0;34mYou do not have \e[4;34mCommand Line Tools for Xcode\e[0m\e[0;34m installed.\e[0m"
  echo -e "\e[0;32mStarting installation now...\e[0m"
  # xcode-select --install
  echo -e "\e[0;33mPress Enter when installation is finished.\e[0m"
  read
fi

# Install Homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Clone or update local clone of dev-setup-macos
LOCAL_DEV_SETUP_MACOS="$HOME/.dev-setup-macos"

if [ -d "$LOCAL_DEV_SETUP_MACOS" ]
then
  # Already have it cloned, will update it instead of cloning it again
  git --git-dir "$LOCAL_DEV_SETUP_MACOS" fetch origin
  git --git-dir "$LOCAL_DEV_SETUP_MACOS" reset --hard origin/master
else
  # We don't have it cloned, let's clone it !
  git clone https://github.com/BESTSELLER/dev-setup-macos.git "$LOCAL_DEV_SETUP_MACOS"
fi

brew bundle --file="$LOCAL_DEV_SETUP_MACOS/.Brewfile"

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)" "" --unattended

# Disable mouse acceleration
defaults write .GlobalPreferences com.apple.mouse.scaling -1

### Keyboard settings ###
# Keyboard --> Key Repeat: Fast (all the way to the right)
defaults write -g InitialKeyRepeat -int 15

# Keyboard --> Delay Until Repeat: Short (all the way to the right)
defaults write -g KeyRepeat -int 2

# Keyboard --> Text --> Untick "Correct spelling automatically"
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false

# Keyboard --> Text --> Untick "Add full stop with double-space"
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false

# Keyboard --> Text --> Untick "Use smart quotes and dashes"
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false

# Set keyboard shortcut "Move focus to next window" to Command+$
/usr/libexec/PlistBuddy -c 'Delete :AppleSymbolicHotKeys:27' ~/Library/Preferences/com.apple.symbolichotkeys.plist
/usr/libexec/PlistBuddy -c 'Add :AppleSymbolicHotKeys:27:enabled bool 1' ~/Library/Preferences/com.apple.symbolichotkeys.plist
/usr/libexec/PlistBuddy -c 'Add :AppleSymbolicHotKeys:27:value:type string standard' ~/Library/Preferences/com.apple.symbolichotkeys.plist
/usr/libexec/PlistBuddy -c 'Add :AppleSymbolicHotKeys:27:value:parameters array' ~/Library/Preferences/com.apple.symbolichotkeys.plist
/usr/libexec/PlistBuddy -c 'Add :AppleSymbolicHotKeys:27:value:parameters:0 integer 36' ~/Library/Preferences/com.apple.symbolichotkeys.plist
/usr/libexec/PlistBuddy -c 'Add :AppleSymbolicHotKeys:27:value:parameters:1 integer 10' ~/Library/Preferences/com.apple.symbolichotkeys.plist
/usr/libexec/PlistBuddy -c 'Add :AppleSymbolicHotKeys:27:value:parameters:2 integer 1048576' ~/Library/Preferences/com.apple.symbolichotkeys.plist

# font fix
if [ -d "$HOME/fonts" ]
then
  # Already have it cloned, will update it instead of cloning it again
  git --git-dir "$HOME/fonts" fetch origin
  git --git-dir "$HOME/fonts" reset --hard origin/master
else
  # We don't have it cloned, let's clone it !
  git clone https://github.com/powerline/fonts.git --depth=1 "$HOME/fonts"
fi

cp -r "$HOME"/fonts/*/*.ttf /Library/Fonts/.
rm -rf "$HOME/fonts"

# Create and set default profile for iTerm2
ITERM_PROFILE_PATH="$HOME/.iterm"
mkdir "$ITERM_PROFILE_PATH"
cp "$LOCAL_DEV_SETUP_MACOS/com.googlecode.iterm2.plist" "$ITERM_PROFILE_PATH/com.googlecode.iterm2.plist"
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$ITERM_PROFILE_PATH"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

# code --list-extensions
cat "$LOCAL_DEV_SETUP_MACOS/vscode.extensions" | xargs -L1 code --install-extension


# Default settings for vscode
if ! [ -f "$HOME/Library/Application Support/Code/User/settings.json" ]
then
  cp "$LOCAL_DEV_SETUP_MACOS/vscode-settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
fi

# Download iTerm2 shell integration
curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh

export ZSH_PATH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH_PATH/custom"

# kubectl-prompt
if [ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-kubectl-prompt" ]
then
  # Already have it cloned, will update it instead of cloning it again
  git --git-dir "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-kubectl-prompt" fetch origin
  git --git-dir "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-kubectl-prompt" reset --hard origin/master
else
  # We don't have it cloned, let's clone it !
  git clone https://github.com/superbrothers/zsh-kubectl-prompt.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-kubectl-prompt"
fi

# We should have a look at this and make bit nicier, so we don't break stuff if people run this script again
cp "$LOCAL_DEV_SETUP_MACOS/.zshrc" "$HOME/.zshrc"

cp "$LOCAL_DEV_SETUP_MACOS/scripts/config-clean.zsh" "$ZSH_CUSTOM/config-clean.zsh"

cp "$LOCAL_DEV_SETUP_MACOS/scripts/aks-list.zsh" "$ZSH_CUSTOM/aks-list.zsh"
cp "$LOCAL_DEV_SETUP_MACOS/scripts/aks-login.zsh" "$ZSH_CUSTOM/aks-login.zsh"

cp "$LOCAL_DEV_SETUP_MACOS/scripts/gke-list.zsh" "$ZSH_CUSTOM/gke-list.zsh"
cp "$LOCAL_DEV_SETUP_MACOS/scripts/gke-login.zsh" "$ZSH_CUSTOM/gke-login.zsh"

mkdir -p "$ZSH_PATH/completions"
cp "$LOCAL_DEV_SETUP_MACOS/scripts/_rerun" "$ZSH_PATH/completions/_rerun"
cp "$LOCAL_DEV_SETUP_MACOS/scripts/rerun" "/usr/local/bin/rerun"
chmod +x "/usr/local/bin/rerun"

(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
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
