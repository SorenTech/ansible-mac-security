# Ansible Mac Security Playbook


A set of ansible playbooks to set up a new Mac with security and privacy best pr

This playbook contains roles that will provide a baseline of security and privacy for a new Mac. It is based in large part on [drduh's MacOS Security and Privacy Guide](https://github.com/drduh/macOS-Security-and-Privacy-Guide).

## What This Playbook Does:
- Create two user accounts: a "Standard User" and an "Admin User" to wall-off administrator functions from day-to-day operations
- Using the admin user, install and configure a number of CLI and GUI tools that will improve the users security and privacy.
- Enable/Configure the built-in Firewall
- For Laptop computers, enable stealth mode, disable mDNS, and disable the Captive Portal dialogue
- Sets a number of security and privacy related defaults

## Tools Installed:

### CLI Tools:

These tools are installed using Homebrew:
- openssl (`brew link`-ed so as to override default openssl)
- curl --with-openssl (`brew link`-ed)
- gnupg
- dnscrypt-proxy (using [drduh config]() and started as a login item)
- dnsmasq —with-dnssec (using [drduh config]() and started as a login item)
- privoxy (using [drduh config]() and started as a login item)

### GUI Tools:
These tools are installed using Homebrew Cask:
- Security Growler
- KnockKnock
- RansomWhere?
- BlockBlock
- Firefox

## Default System Settings Configured:
- Show hidden files in finder
- Show all file extensions by default
- Disable iCloud default save destination
- Check for software updates daily
- Require password upon sleep
- Empty trash securely by default
- Don’t send safari search queries to Apple
- Prevent safari from opening “safe” files automatically after download

## Other Stuff:
- Adds a cron-job in the admin account to run `brew upgrade` daily in the early-am

