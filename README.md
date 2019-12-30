# Ansible Mac Security Baseline

This playbook will provide a baseline of security and privacy for a new Mac. It is based in large part on [drduh's MacOS Security and Privacy Guide](https://github.com/drduh/macOS-Security-and-Privacy-Guide). **Obvious disclaimer: You are responsible for your own computer's security and using this playbook does not guarantee anything.** It provides a set of defaults and installs packages that will improve the basic security posture of your machine, but do not ensure it's protection or your privacy.

## Installation

Quick install method: 

`$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/apmarshall/mac-dev-playbook/master/install.sh)"`

> Note: If some Homebrew commands fail, you might need to agree to Xcode's license or fix some other Brew issue. Run `brew doctor` to see if this is the case.

### Running a specific set of tagged tasks

You can filter which part of the provisioning process to run by specifying a set of tags using `ansible-playbook`'s `--tags` flag.

    ansible-playbook main.yml -i inventory -K --tags "homebrew"

## Overriding Defaults

You can override any of the defaults configured in `default.config.yml` by creating a `config.yml` file and setting the overrides in that file. For example, you can customize the installed packages and apps with something like:

    homebrew_installed_packages:
      - cowsay
      - git
      - go
    
    mas_installed_apps:
      - { id: 443987910, name: "1Password" }
      - { id: 498486288, name: "Quick Resizer" }
      - { id: 557168941, name: "Tweetbot" }
      - { id: 497799835, name: "Xcode" }
    
    composer_packages:
      - name: hirak/prestissimo
      - name: drush/drush
        version: '^8.1'
    
    gem_packages:
      - name: bundler
        state: latest
    
    npm_packages:
      - name: webpack
    
    pip_packages:
      - name: mkdocs

Any variable can be overridden in `config.yml`; see the supporting roles' documentation for a complete list of available variables.

## What This Playbook Does:
- Configure curl based on drduh's recomendations
- Install xcode tools and Homebrew
- Using Homebrew, installs a number of CLI and GUI packages that improve security and privacy (see below)
- Sets baseline security system settings, including turning on the Firewall and enabling automatic critical updates
- Configures the computer's DNS and secure web proxy using dnscrypt-proxy, dnsmasq, and privoxy.

## Goals:
- Automatically create two user accounts: a "Standard User" and an "Admin User" to wall-off administrator functions from day-to-day operations
- Using the admin user, install and configure a number of CLI and GUI tools that will improve the users security and privacy.
- Customize options for laptops vs. desktops. Ie, For Laptop computers, enable stealth mode, disable mDNS, and disable the Captive Portal dialogue
- Configure automatic updates to installed packages, hosts files, and configuration recomendations

## Tools Installed:

### CLI Tools:

These tools are installed using Homebrew:
- bitwarden-cli 
- dnscrypt-proxy (using [drduh config]() and started as a login item)
- dnsmasq (using [drduh config]() and started as a login item)
- gnupg (as of yet, not configured)
- privoxy (using [drduh config]() and started as a login item)
- python3 (used to manage host files using Stephen Black's project)

### GUI Tools:
These tools are installed using Homebrew Cask:
  - bitwarden
  - blockblock
  - dhs
  - kextviewr
  - knockknock
  - lockdown
  - lulu
  - netiquette
  - oversight
  - ransomwhere
  - reikey
  - security-growler
  - taskexplorer
  - whatsyoursign

## Default System Settings Configured:
- Turn on the built-in firewall
- Show hidden files in finder
- Show all file extensions by default
- Disable iCloud default save destination
- Check for software updates daily
- Require password upon sleep/screensaver
- Empty trash securely by default
- Don’t send safari search queries to Apple
- Prevent safari from opening “safe” files automatically after download
- Send "do-not-track" requests from Safari
