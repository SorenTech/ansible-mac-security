# Ansible Mac Security Baseline

This playbook will provide a baseline of security and privacy for a new Mac. It is based in large part on the CIS Benchmarks for MacOS and [drduh's MacOS Security and Privacy Guide](https://github.com/drduh/macOS-Security-and-Privacy-Guide). **Disclaimer: You are responsible for your own computer's security and using this playbook does not guarantee anything.** It provides a set of defaults and installs packages that will improve the basic security posture of your machine, but does not guarantee it's security or your privacy.

## Installation

Quick install method: 

`$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/SorenTech/ansible-mac-security/master/install.sh)"`

> Note: If some Homebrew commands fail, you might need to agree to Xcode's license or fix some other Brew issue. Run `brew doctor` to see if this is the case.

## Overriding Defaults

You can override any of the defaults configured in `default.config.yml` by creating a `config.yml` file and setting the overrides in that file. For example, you can customize the installed packages and apps with something like:

    homebrew_installed_packages:
      - cowsay
      - git
      - go
    
Any variable can be overridden in `config.yml`; see the supporting roles' documentation for a complete list of available variables. However, be aware that if you remove `dnscrypt-proxy`, `dnsmasq`, or `python3` from the list you may break other parts of the playbook that depend on these being present.

## What This Playbook Does:
- Configure curl based on drduh's recomendations
- Ensure XCode and Homebrew are correctly installed and configured
- Using Homebrew, installs a number of CLI and GUI packages that improve security and privacy (see below)
- Sets baseline security system settings based on the CIS Benchmarks for MacOS and DrDuh's recommendations
- Configures the computer's DNS to use dnscrypt-proxy and dnsmasq with blocklists provided by Steven Black's Hostfile project

## RoadMap:
- Automatically create two user accounts: a "Standard User" and an "Admin User" to wall-off administrator functions from day-to-day operations
- Configure a launchdaemon to automaticly update installed packages, hosts files, and configuration recomendations

## Tools Installed:

### CLI Tools:

These tools are installed using Homebrew:
- bitwarden-cli 
- dnscrypt-proxy (using [drduh config]() and started as a login item)
- dnsmasq (using [drduh config]() and started as a login item)
- gnupg (as of yet, not configured)
- python3 (used to manage host files using Stephen Black's project)

### GUI Tools:
These tools are installed using Homebrew Cask:
  - bitwarden
  - blockblock
  - dhs
  - do-not-disturb
  - firefox
  - google-chrome
  - kextviewr
  - knockknock
  - lockdown
  - lulu
  - netiquette
  - oversight
  - ransomwhere
  - reikey
  - taskexplorer
  - whatsyoursign

## Note on CIS Benchamrks
Some CIS benchmarks are intentionally not configured because they are not really applicable to a personal system (ie, benchmarks about disabling iCloud Drive). Others are still a work in progress. Check out [settings.yml](https://github.com/SorenTech/ansible-mac-security/blob/master/tasks/settings.yml) for more details.
