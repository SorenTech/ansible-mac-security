#!/usr/bin/env bash

# Simple Install Script to Set Up Security Baseline on a New Mac with One Command Using Curl
# What it does:
# - Install pip (if needed) and then install Ansible with pip
# - Clone Ansible Playbook with git
# - Run Ansible Playbook to Configure New Mac (including installing xcode tools and homebrew)

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `install.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install pip and ansible if they aren't already on the system 
if [ -x "$(command -v pip)" ]; then
    sudo easy_install pip
fi

if [ -x "$(command -v ansible)" ]; then
    sudo pip install ansible
fi

# Add ansible.cfg to pick up roles path.
"{ echo '[defaults]'; echo 'roles_path = ../'; } >> ansible.cfg"

# Add a hosts file.
sudo mkdir -p /etc/ansible
sudo touch /etc/ansible/hosts
"echo -e '[local]\nlocalhost ansible_connection=local' | sudo tee -a /etc/ansible/hosts > /dev/null"

# clone repo
git clone https://github.com/SorenTech/ansible-mac-security.git ~/.baseline
cd ~/.baseline

# install requirements
ansible-galaxy install -r requirements.yml

# check syntax
ansible-playbook main.yml --syntax-check

# run playbook
ansible-playbook --extra-vars '{\"configure_sudoers\":\"false\"}' main.yml
