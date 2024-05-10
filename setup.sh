#!/bin/bash

if [ "$(id -u)" = 0 ]; then
    echo "######################################################################"
    echo "This script should NOT be run as root user as it may create unexpected"
    echo " problems and you may have to reinstall Arch. So run this script as a"
    echo "  normal user. You will be asked for a sudo password when necessary"
    echo "######################################################################"
    exit 1
fi

sudo cp sources.list /etc/apt/
sudo apt update
sudo apt upgrade

echo ""
read -r -p "Do you want to install AMD/ATI drivers? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sudo apt install -y firmware-amd-graphics libgl1-mesa-dri libglx-mesa0 mesa-vulkan-drivers xserver-xorg-video-all
fi

echo ""
read -r -p "Do you want to install Nvidia drivers(Maxwell+)? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sudo apt install -y nvidia-driver firmware-misc-nonfree nvidia-suspend-common
    echo 'GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX nvidia-drm.modeset=1"' | sudo tee /etc/default/grub.d/nvidia-modeset.cfg > /dev/null
    sudo update-grub
    sudo systemctl enable nvidia-suspend.service
    sudo systemctl enable nvidia-hibernate.service
    sudo systemctl enable nvidia-resume.service
    echo 'options nvidia NVreg_PreserveVideoMemoryAllocations=1' | sudo tee /etc/modprobe.d/nvidia-power-management.conf > /dev/null
fi

sudo apt install -y $(cat tpkg)
sudo systemctl enable --now ufw
sudo ufw enable
chsh -s /usr/bin/fish
sudo chsh -s /usr/bin/fish
echo -e "VISUAL=nvim\nEDITOR=nvim" | sudo tee /etc/environment > /dev/null

echo ""
echo "Installing WhiteSur Icon and GTK Theme..."
echo ""
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git --depth=1
cd WhiteSur-icon-theme/
sudo ./install.sh -a
cd ..
rm -rf WhiteSur-icon-theme/

git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
cd WhiteSur-gtk-theme/
sudo ./install.sh
cd ..
rm -rf WhiteSur-gtk-theme/

echo ""
echo "Installing XFCE..."
echo ""
sudo apt install -y $(cat xfce)
sudo systemctl enable lightdm.service

echo ""
read -r -p "Do you want to configure git? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    read -p "Enter your Git name: " git_name
    read -p "Enter your Git email: " git_email
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    ssh-keygen -t ed25519 -C "$git_email"
    git config --global gpg.format ssh
    git config --global user.signingkey /home/$un/.ssh/id_ed25519.pub
    git config --global commit.gpgsign true
fi

echo ""
read -r -p "Do you want to install Firefox? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sudo apt install -y firefox-esr
fi

echo ""
read -r -p "Do you want to install Chromium? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sudo apt install -y chromium
fi

echo ""
read -r -p "Do you want Bluetooth Service? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sudo apt install -y bluetooth blueman
    sudo systemctl enable bluetooth.service
fi

echo ""
read -r -p "Do you want to install HPLIP (Driver for HP printers)? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sudo apt install -y hplip
    hp-plugin -i
fi

echo ""
read -r -p "Do you want to install VSCode? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    rm -f packages.microsoft.gpg
    sudo apt install -y apt-transport-https
    sudo apt update
    sudo apt install code
fi

echo ""
read -r -p "Do you want to install Telegram? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sudo apt install -y telegram-desktop
fi

echo ""
read -r -p "Do you want to install Cloudflare Warp? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
    sudo apt update && sudo apt install cloudflare-warp
fi

cp QtProject.conf ~/.config/

echo ""
echo "You can now reboot your system"
