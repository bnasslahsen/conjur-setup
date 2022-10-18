#!/bin/bash

# CREATE:conjur master instance

# Global Variables
containerName=conjur-12.7
conjurBinary=~/conjur-appliance-Rls-12.7.tar.gz
conjurImage=conjur-appliance:12.7.0.1
conjurService=conjur.service
masterDNS=conjur.demo.cybr
conjurAccount=devsecops
podmanUser=ec2-user

# Create conjur master
echo "Creating conjur master"
echo "------------------------------------"
set -x
## Enable IPv4 forwarding
sudo sysctl -w net.ipv4.ip_forward=1
systemctl --user disable $conjurService
systemctl --user  list-unit-files | grep $conjurService
podman load -i $conjurBinary
podman images
podman rm --ignore --force $containerName

sudo mkdir -p /opt/cyberark/dap/{config,security,backups,seeds,logs,certs}
#for podman
sudo chown $podmanUser:$podmanUser /opt/cyberark/dap/{security,config,backups,seeds,logs}

podman run \
    --name $containerName \
    --detach \
    --restart=unless-stopped \
    --security-opt seccomp=unconfined \
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

podman logs --since=2m $containerName

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