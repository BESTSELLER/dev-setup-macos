#!/bin/bash 

# exit when any command fails
set -e

# Check if we are admin before continuing
if ! sudo -l &> /dev/null;
then
  echo -e "\033[0;31mYou are not admin !\033[0m"
  echo -e "\033[0;31mPlease become admin and then re-run this script.\033[0m"
  exit 1
fi

# Make sure Command Line Tools for Xcode is installed before installing Homebrew
if ! xcode-select -p &> /dev/null ; then
  echo -e "\033[0;34mYou do not have \033[4;34mCommand Line Tools for Xcode\033[0m\033[0;34m installed.\033[0m"
  echo -e "\033[0;32mStarting installation now...\033[0m"
  # xcode-select --install
  echo -e "\033[0;33mPress Enter when installation has finished.\033[0m"
  read -r
fi

# Install Homebrew
if ! command -v brew &> /dev/null;
then
  echo -e "\033[0;31mPlease make sure that Homebrew is installed !!\033[0m"
  exit 1
fi

# Clone or update local clone of dev-setup-macos
LOCAL_DEV_SETUP_MACOS="$HOME/.dev-setup-macos"

if [ -d "$LOCAL_DEV_SETUP_MACOS" ]
then
  # Already have it cloned, will update it instead of cloning it again
  (
    cd "$LOCAL_DEV_SETUP_MACOS"
    git fetch origin
    git reset --hard origin
    git pull
  )
else
  # We don't have it cloned, let's clone it !
  git clone https://github.com/BESTSELLER/dev-setup-macos.git "$LOCAL_DEV_SETUP_MACOS"
fi

brew bundle --no-lock --file="$LOCAL_DEV_SETUP_MACOS/.Brewfile"

# Install Oh My Zsh
if [ ! -d ~/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)" "" --unattended
fi

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
/usr/libexec/PlistBuddy -c 'Delete :AppleSymbolicHotKeys:27' ~/Library/Preferences/com.apple.symbolichotkeys.plist || true
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
  (
    cd "$HOME"/fonts
    git fetch origin
    git reset --hard origin
    git pull
  )
else
  # We don't have it cloned, let's clone it !
  git clone https://github.com/powerline/fonts.git --depth=1 "$HOME/fonts"
fi

cp -r "$HOME"/fonts/*/*.ttf /Library/Fonts/.

# Create and set default profile for iTerm2
ITERM_PROFILE_PATH="$HOME/.iterm"
if [ ! -d "$ITERM_PROFILE_PATH" ]; then
  mkdir "$ITERM_PROFILE_PATH"
  cp "$LOCAL_DEV_SETUP_MACOS/com.googlecode.iterm2.plist" "$ITERM_PROFILE_PATH/com.googlecode.iterm2.plist"
  defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$ITERM_PROFILE_PATH"
  defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
fi

# Install vscode extensions
echo "Do you want to install VSCode extentions [y/N]"
read -r vscodeExtensions
if [ "$vscodeExtensions" != "${vscodeExtensions#[Yy]}" ] ;then # this grammar (the #[] operator) means that the variable $vscodeExtensions where any Y or y in 1st position will be dropped if they exist.
  while read -r p; do
    code --install-extension "$p"
  done <"$LOCAL_DEV_SETUP_MACOS/vscode.extensions"
fi

# Default settings for vscode
echo "Do you want to install VSCode settings [y/N]"
read -r vscodeSettings
if [ "$vscodeSettings" != "${vscodeSettings#[Yy]}" ] ;then # this grammar (the #[] operator) means that the variable $vscodeSettings where any Y or y in 1st position will be dropped if they exist.
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
  
  (
    cd "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-kubectl-prompt"
    git fetch origin
    git reset --hard origin
    git pull
  )
else
  # We don't have it cloned, let's clone it !
  git clone https://github.com/superbrothers/zsh-kubectl-prompt.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-kubectl-prompt"
fi

# kubectl-prompt
if [ -d "${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions" ]
then
  # Already have it cloned, will update it instead of cloning it again
  
  (
    cd "${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions"
    git fetch origin
    git reset --hard origin
    git pull
  )
else
  # We don't have it cloned, let's clone it !
  git clone https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}"/plugins/zsh-completions
fi

# Add a default .zshrc
echo "Do you want to override your .zshrc file? [y/N]"
read -r profileOverride
if [ "$profileOverride" != "${profileOverride#[Yy]}" ] ;then # this grammar (the #[] operator) means that the variable $profileOverride where any Y or y in 1st position will be dropped if they exist.
    cp "$LOCAL_DEV_SETUP_MACOS/.zshrc" "$HOME/.zshrc"
fi

# Add our custom scripts
cp "$LOCAL_DEV_SETUP_MACOS/scripts/config-clean.zsh" "$ZSH_CUSTOM/config-clean.zsh"
cp "$LOCAL_DEV_SETUP_MACOS/scripts/aks-list.zsh" "$ZSH_CUSTOM/aks-list.zsh"
cp "$LOCAL_DEV_SETUP_MACOS/scripts/aks-login.zsh" "$ZSH_CUSTOM/aks-login.zsh"
cp "$LOCAL_DEV_SETUP_MACOS/scripts/gke-list.zsh" "$ZSH_CUSTOM/gke-list.zsh"
cp "$LOCAL_DEV_SETUP_MACOS/scripts/gke-login.zsh" "$ZSH_CUSTOM/gke-login.zsh"

mkdir -p "$ZSH_PATH/completions"
cp "$LOCAL_DEV_SETUP_MACOS/scripts/_rerun" "$ZSH_PATH/completions/_rerun"
sudo cp "$LOCAL_DEV_SETUP_MACOS/scripts/rerun" "/usr/local/bin/rerun"
sudo chmod +x "/usr/local/bin/rerun"

# This will install krew
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

export USE_GKE_GCLOUD_AUTH_PLUGIN=False
gcloud components install gke-gcloud-auth-plugin -q

# Install flux completion
flux completion zsh > "$ZSH_PATH/completions/_flux"

# Fixing kubectx and kubens completions
ln -s "$(brew --prefix kubectx)/share/zsh/site-functions/_kubectx" "$ZSH_PATH/completions/"
ln -s "$(brew --prefix kubectx)/share/zsh/site-functions/_kubens" "$ZSH_PATH/completions/"


# Check if git email and name are set
if [ -z "$(git config --global user.email)" ]
then
  echo Enter your e-mail:
  read -r gitEmail
  git config --global user.email "$gitEmail"
  echo Enter your name:
  read -r gitName
  git config --global user.name "$gitName"
fi

echo -e "\033[0;32mInstallation completed! \033[0m"
