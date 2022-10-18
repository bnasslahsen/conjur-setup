#!/bin/bash

# CREATE:conjur master instance

# Global Variables
containerName="12.7"
conjurBinary="~/conjur-appliance-Rls-12.7.tar.gz"
conjurImage=conjur-appliance:12.7.0.1
conjurService=conjur.service
masterDNS="conjur.demo.cybr"
conjurAccount=devsecops

# Create conjur master
echo "Creating conjur master"
echo "------------------------------------"
set -x

systemctl --user disable $conjurService
systemctl --user  list-unit-files | grep $conjurService

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

curl -k https://$(hostname -f)/health

# Create Conjur service
sudo loginctl enable-linger
mkdir -p ~/.config/systemd/user
podman generate systemd $containerName --name --container-prefix="" --separator="" > ~/.config/systemd/user/$conjurService
systemctl --user daemon-reload
systemctl --user enable $conjurService
systemctl --user  list-unit-files | grep $conjurService
systemctl --user status $conjurService