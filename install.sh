#!/bin/bash

set -e
set -u
set -x

# Simple Install Script to Set Up Security Baseline on a New Mac with One Command Using Curl
# Prerequisites: Install Python for your particular Mac Architecture (whether that is intel or M1)
# What it does:
# - Installs Homebrew if not present
# - Installs and Configures Ansible if not present
# - Clone/Update Ansible Playbook with git
# - Run Ansible Playbook to Configure New Mac (including installing xcode tools and homebrew)

should_install_homebrew() {
  ! [[ -e "${HOMEBREW_PREFIX}/bin/brew" ]]
}

no_python3() {
  ! [[ -e "/usr/local/bin/2to3" ]]
}

should_install_ansible() {
  ! [[ -x "$(command -v ansible)" ]]
}

should_clone_repo() {
  ! [[ -e "~/.baseline/.git" ]]
}

should_configure_ansible() {
  ! [[ -e "/etc/ansible/ansible.cfg" ]]
}

run_playbook() {
  if $CICD_TEST == true; then
    PLAYBOOK_ARGS='--skip-tags "homebrew" -vv'
  else
    PLAYBOOK_ARGS=""
  fi
  ansible-playbook main.yml -i inventory --extra-vars '{\"configure_sudoers\":\"false\"}' $PLAYBOOK_ARGS
}

system_setup() {
  if ! $CICD_TEST
  then
      # Ask for the administrator password upfront
      sudo -v

      # Keep-alive: update existing `sudo` time stamp until `install.sh` has finished
      while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &  
  fi
  
  if ! [[ "$(uname)" == "Darwin" ]] 
  then
    echo "Error: This script can only be run on a MacOS System"
    exit 1
  else
    if [[ "$(/usr/bin/uname -m)" == "arm64" ]]
    then 
      HOMEBREW_PREFIX="/opt/homebrew"
    else
      HOMEBREW_PREFIX="/usr/local"
    fi
  fi

  if should_install_homebrew
  then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if should_install_ansible
  then
    if no_python3
    then
      brew install ansible
    else
      brew install ansible -f
    fi
  fi

  if should_clone_repo
  then
    git clone https://github.com/SorenTech/ansible-mac-security.git ~/.baseline
  else
    cd ~/.baseline && git pull
  fi

  cd ~/.baseline && \
    echo "Installing playbook requirements" && \
    ansible-galaxy install -r requirements.yml && \
    echo "Testing playbook syntax" && \
    ansible-playbook main.yml -i inventory --syntax-check && \
    echo "Running playbook" && \
    run_playbook && \
    echo "Playbook completed"
    
  exit 0
}

if [[ $1=="-t" ]]
then
  CICD_TEST=true
else
  CICD_TEST=false
fi

system_setup
