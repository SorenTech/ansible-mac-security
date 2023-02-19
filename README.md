# Ansible Mac Security Baseline

This playbook will provide a baseline of security and privacy for a new Mac. It is based in large part on the CIS Benchmarks for MacOS and [drduh's MacOS Security and Privacy Guide](https://github.com/drduh/macOS-Security-and-Privacy-Guide). **Disclaimer: You are responsible for your own computer's security and using this playbook does not guarantee anything.** It provides a set of defaults and installs packages that will improve the basic security posture of your machine, but does not guarantee it's security or your privacy.

## Installation

Quick install method: 

`$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/SorenTech/ansible-mac-security/master/install.sh)"`

> Note: If some Homebrew commands fail, you might need to agree to Xcode's license or fix some other Brew issue. Run `brew doctor` to see if this is the case.

### Ideal Workflow

This is meant as a set-up script for a new device. Ideally you should:
1. Start up the new device and create a designated "admin" account
2. Run the install command above from your terminal
3. Create a second "standard" account (ie, no admin privileges)
4. Log out of admin, log into standard
5. Use standard for day-to-day activities (including linking to Apple-ID, if desired)

You can re-run the playbook to get the latest changes. First log into your admin account. Then:
```sh
cd ~/.baseline
git pull
ansible-playbook main.yml --skip-tags "install-only"
```

It's on the roadmap to automate that update process via a launchdaemon or cron job.

If you get an error about needing sudo permissions for any of the steps in the playbook during a subsequent run, initate sudo with `sudo -v` first, then re-run `ansible-playbook main.yml --skip-tags "install-only"`

### If Running on an Existing Device
You can also use the same curl -> bash method on an established machine, but with a couple of caveats:
1. If you already have a designated "admin" account, make sure you run this from that account
2. If you already have dnsmasq or dnscrypt-proxy running as homebrew services, don't use the install script. Instead, clone the repo and run the playbook direclty using `ansible-playbook main.yml --skip-tags "install-only"`

## Overriding Defaults

You can override any of the defaults configured in `default.config.yml` by creating a `config.yml` file and setting the overrides in that file. For example, you can customize the installed packages and apps with something like:

    homebrew_installed_packages:
      - cowsay
      - git
      - go
    
Any variable can be overridden in `config.yml`; see the supporting roles' documentation for a complete list of available variables. 

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
