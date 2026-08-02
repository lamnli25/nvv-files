#!/bin/bash

# Vorige Installationen deinstallieren
apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc | cut -f1)

# Add Docker's official GPG key:
apt update
apt install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# Packetquellen updaten
apt update

# Install docker community edition and plugins
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# check install
systemctl restart docker
systemctl status docker

# run test-image
docker run hello-world

# Dienst automatisch starten
systemctl enable docker

# Festplatte vorbereiten



mkdir -p /mnt/docker
mount /dev/sdb1 /mnt/docker




# Mount Punkt automatisch einhängen
FSTAB="/etc/fstab"
ENTRY="/dev/sdb1  /mnt/docker  ext4  defaults  0  2"

if grep -qF "$ENTRY" "$FSTAB"; then
    echo "Eintrag existiert bereits."
else
    echo "$ENTRY" | sudo tee -a "$FSTAB"
    echo "Eintrag hinzugefügt."
fi
