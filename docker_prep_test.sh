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

ead -p "Festplatte eingeben (z.B. /dev/sdb): " diskk

disk=/dev/$diskk

if [[ ! -b "$disk" ]]; then
    echo "Fehler: $disk ist kein gültiges Blockgerät."
    exit 1
fi

echo "ACHTUNG: Folgende Platte wird partitioniert:"
lsblk "$disk"

read -p "Fortfahren? (j/n): " confirm

if [[ "$confirm" != "j" ]]; then
    echo "Abgebrochen."
    exit 0
fi

echo -e "g\nn\n\n\n\nw" | sudo fdisk "$disk"

# Filesystem erstelln
mkfs.ext4 /dev/"$diskk"1

# Filesystem prüfen
blkid /dev/sdb1

# Eingabe des Namens vom Mountpoint
read -p "Fortfahren mit erstellen des Mountpoints? (j/n): " confirm
read -p "Name des Mountpunktes eingeben: " montpnt

# Mountpoint erzeugen
mkdir -p /mnt/$montpnt
mount /dev/"$diskk"1 /mnt/$montpnt

# Mount Punkt automatisch einhängen
FSTAB="/etc/fstab"
ENTRY="/dev/sdb1  /mnt/docker  ext4  defaults  0  2"

if grep -qF "$ENTRY" "$FSTAB"; then
    echo "Eintrag existiert bereits."
else
    echo "$ENTRY" | sudo tee -a "$FSTAB"
    echo "Eintrag hinzugefügt."
fi

# Rechte Zuweisung
