#!/bin/bash

# Simple Install Script to Set Up Security Baseline on a New Mac with One Command Using Curl
# Prerequisites: Install Python for your particular Mac Architecture (whether that is intel or M1)
# What it does:
# - Install Ansible with pip
# - Clone Ansible Playbook with git
# - Run Ansible Playbook to Configure New Mac (including installing xcode tools and homebrew)

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `install.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

sudo pip install ansible-core &&

# Add ansible.cfg to pick up roles path.
echo "[defaults]\n roles_path = ../" >> ansible.cfg

# Add a hosts file.
sudo mkdir -p /etc/ansible &&
sudo touch /etc/ansible/hosts &&
echo "[local]\n localhost ansible_connection=local" | sudo tee -a /etc/ansible/hosts >/dev/null &&

# clone repo
git clone https://github.com/SorenTech/ansible-mac-security.git ~/.baseline &&
cd ~/.baseline &&

# install requirements
ansible-galaxy install -r requirements.yml &&

# check syntax
ansible-playbook main.yml --syntax-check &&

# run playbook
ansible-playbook --extra-vars '{\"configure_sudoers\":\"false\"}' main.yml
