#!/bin/bash

# Global Variables
conjurURL=$(hostname -f)
conjurAccount=deutsche-telekom
conjurUser=admin
conjurPassword="$(cat admin_password)"

# Init Conjur CLI
echo "Init Conjur CLI"
echo "------------------------------------"
set -x
printf 'yes\nyes\nyes\nyes' | conjur init --s --url https://$conjurURL --account $conjurAccount
set +x
# Login to Conjur CLI
conjur login -i $conjurUser -p $conjurPassword
