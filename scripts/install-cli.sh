#!/bin/bash

# Install Conjur CLI

# Global Variables
conjurCliReleasesUrl=https://github.com/cyberark/cyberark-conjur-cli/releases/download/v7.1.0
conjurCliFile="conjur-cli-rhel-8.tar.gz"
conjurUrl="https://conjur-follower-eu.demo.cybr"
conjurAccount="deutsche-telekom"
conjurUser="admin"
conjurPass="MySecretP@ss1"

# Install Conjur CLI
echo "Install Conjur CLI"
echo "------------------------------------"
set -x
curl -L -O $conjurCliReleasesUrl/$conjurCliFile
tar -xvf $conjurCliFile
chmod +x conjur
sudo mv conjur /usr/local/bin
conjur --version
conjur init --s --url $conjurUrl --account $conjurAccount --force
conjur login -i $conjurUser -p $conjurPass
set +x