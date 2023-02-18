#!/bin/bash

set -e
set -u
set -x

PLAYBOOK_ARGS=""
CICD_TEST=false

# Simple Install Script to Set Up Security Baseline on a New Mac with One Command Using Curl
# Prerequisites: Install Python for your particular Mac Architecture (whether that is intel or M1)
# What it does:
# - Installs Homebrew if not present
# - Installs and Configures Ansible if not present
# - Clone/Update Ansible Playbook with git
# - Run Ansible Playbook to Configure New Mac (including installing xcode tools and homebrew)

should_install_homebrew() {
  ! [[ -e "/usr/local/bin/brew" ]] || ! [[ -e "/opt/homebrew/bin/brew" ]]
}

should_install_ansible() {
  ! [[ ansible --version ]]
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
  fi
  ansible-playbook main.yml -i inventory --extra-vars '{\"configure_sudoers\":\"false\"}' $PLAYBOOK_ARGS
}

system_setup() {
  if should_install_homebrew
  then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if should_install_ansible
  then
    brew install ansible
  fi

  if should_clone_repo
  then
    git clone https://github.com/SorenTech/ansible-mac-security.git ~/.baseline
  else
    cd ~/.baseline && git pull
  fi

  if should_configure_ansible
  then
    cp ~/.baseline/ansible.cfg /etc/ansible/ansible.cfg
  fi

  if CICD_TEST == false; do
    # Ask for the administrator password upfront
    sudo -v

    # Keep-alive: update existing `sudo` time stamp until `install.sh` has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &    
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

for arg in "$@"
do
  case "$arg" in
    -t) CICD_TEST=true
        ;;
    *) echo "Unrecognized argument"
       exit 1
       ;;
   esac
done

system_setup
