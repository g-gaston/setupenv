#!/bin/bash

set -e
set -o pipefail

# success prints a checkmark followed by the first argument
success() {
  echo "✅ $1"
}

# esnure_command checks if a set of commands are available and installs them if not
ensure_command() {
  for cmd in "$@"; do
    if ! command -v "$cmd" &> /dev/null; then
      case "$(uname)" in
        Darwin)
          brew install "$cmd"
          ;;
        Linux) # For linux, assume ubuntu
          sudo apt install -y "$cmd"
          ;;
        *)
          return 1
          ;;
      esac
      success "$cmd installed"
    else
      success "$cmd already installed"
    fi
  done
}

GITHUB_SSH_KEY_PATH=$HOME/.ssh/github
DEVENV_PATH=$HOME/devenv

# If Mac install hombrew,
if [ "$(uname)" == "Darwin" ]; then
  if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Temporaly add brew to path
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    success "brew installed"
  else
    success "homebrew already installed"
  fi
elif [ "$(uname)" == "Linux" ]; then
  sudo apt update
fi

ensure_command ansible gh

# Generate ssh key for github and store it in .ssh folder if it doesn't exist
[ -f "$GITHUB_SSH_KEY_PATH" ] || ssh-keygen -t ed25519 -C "" -f "$GITHUB_SSH_KEY_PATH" -N ""

# Setup github auth if not set yet
if ! gh auth status > /dev/null 2>&1; then
  # TODO: maybe use the token base auth for machine without graphical interface
  gh auth login --git-protocol ssh --hostname github.com --web
else
  success "gh is already authenticated"
fi

# Clone devenv repo with ansible playbooks
[ -f "$DEVENV_PATH" ] || git clone git@github.com:g-gaston/devenv.git "$DEVENV_PATH"

# Install ansible extra modules
ansible-galaxy install -r "$DEVENV_PATH/ansible/requirements.yml"

# Run ansible playbook with args from this comand
ansible-playbook "$DEVENV_PATH/ansible/main.yml" --ask-become-pass "$@"
