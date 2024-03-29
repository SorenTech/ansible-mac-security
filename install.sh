#!/bin/bash

set -e
set -u
set -x

# Simple Install Script to Set Up Security Baseline on a New Mac with One Command Using Curl
# Prerequisites: Install Python for your particular Mac Architecture (whether that is intel or M1)
# What it does:
# - Installs Homebrew if not present
# - Installs Ansible if not present
# - Clone/Update Ansible Playbook with git
# - Run Ansible Playbook to Configure New Mac

should_install_homebrew() {
  ! [[ -e "${HOMEBREW_PREFIX}/bin/brew" ]]
}

should_add_homebrew_to_path() {
  ! [[ ":${PATH}:" = *":${HOMEBREW_PREFIX}/bin:"* ]]
}

no_python3() {
  ! [[ -e "/usr/local/bin/2to3" ]]
}

should_install_ansible() {
  ! [[ -x "$(command -v ansible)" ]]
}

should_clone_repo() {
  ! [[ -e "$HOME/.baseline/.git" ]]
}

should_configure_ansible() {
  ! [[ -e "/etc/ansible/ansible.cfg" ]]
}

run_playbook() {
  if $CICD_TEST
  then
    echo "Playbook would have run here."
    exit 0
  else
    ansible-playbook main.yml -i inventory --extra-vars '{\"configure_sudoers\":\"false\"}' 
  fi
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
  
  if should_add_homebrew_to_path
  then
    case "${SHELL}" in
      */bash*)
        if [[ -r "${HOME}/.bash_profile" ]]
        then
          shell_profile="${HOME}/.bash_profile"
        else
          shell_profile="${HOME}/.profile"
        fi
        ;;
      */zsh*)
        shell_profile="${HOME}/.zprofile"
        ;;
      *)
        shell_profile="${HOME}/.profile"
        ;;
    esac
    
    (echo; echo 'eval "\$(${HOMEBREW_PREFIX}/bin/brew shellenv)"') >> ${shell_profile}
    eval "\$(${HOMEBREW_PREFIX}/bin/brew shellenv)"
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
    git clone https://github.com/SorenTech/ansible-mac-security.git $HOME/.baseline
  else
    cd $HOME/.baseline && git pull
  fi

  cd $HOME/.baseline && \
    echo "Installing playbook requirements" && \
    ansible-galaxy install -r requirements.yml && \
    echo "Testing playbook syntax" && \
    ansible-playbook main.yml -i inventory --syntax-check && \
    echo "Running playbook" && \
    run_playbook && \
    echo "Playbook completed"
}

if [ $# -ge 1 ] && [ $1 == "-t" ]
then
  CICD_TEST=true
elif [ $# -eq 0 ]
then
  CICD_TEST=false
else
  echo "Error: Unknown Argument $1"
  exit 1
fi

system_setup
