#!/bin/sh

echo "Changing SSH port to 47691..."
sh ./changeSshPort.sh

echo "Disabling SSH login access to root account..."
echo "Creating user servermgmt...
echo "Please type in a password for the new user"
sh ./ChangeSshUser.sh
echo "Editing sudoers file for new account..."

echo "Setting up notice for SSH logins..."
echo "Please type in your email"
sh ./SshMessage.sh

echo "Setting up firewall with secure defaults..."
sh ./firewall.sh start

echo "Installing Golang (v1.13)..."
sh ./InstallGo.sh

echo "Installing Caddyserver..."
sh ./caddy.sh
