#!/bin/bash

# CREATE:conjur master instance

# Global Variables
containerName="12.7"
conjurBinary="conjur-appliance-Rls-12.7.tar.gz"
conjurImage=conjur-appliance:12.7.0.1
masterDNS="conjur-leader.demo.cybr"
conjurAccount=devsecops

# Create conjur master
echo "Creating conjur master"
echo "------------------------------------"
set -x

systemctl --user disable conjur
systemctl --user  list-unit-files | grep conjur

podman load -i $conjurBinary

podman rm --ignore --force $containerName
podman run \
    --name $containerName \
    --detach \
    --restart=unless-stopped \
    --security-opt seccomp=/opt/cyberark/dap/security/seccomp.json \
    --publish "443:443" \
    --publish "444:444" \
    --publish "5432:5432" \
    --publish "1999:1999" \
    --log-driver journald \
    --volume /opt/cyberark/dap/config:/etc/conjur/config:Z \
    --volume /opt/cyberark/dap/security:/opt/cyberark/dap/security:Z \
    --volume /opt/cyberark/dap/backups:/opt/conjur/backup:Z \
    --volume /opt/cyberark/dap/seeds:/opt/cyberark/dap/seeds:Z \
    --volume /opt/cyberark/dap/logs:/var/log/conjur:Z \
    $conjurImage

sleep 10

set +x

podman exec $containerName evoke configure master \
  --accept-eula \
  --hostname $masterDNS \
  --master-altnames $(hostname -s),$(hostname -f) \
  --admin-password="$(cat admin_password)" \
  $conjurAccount
