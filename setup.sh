#!/bin/bash

if [ "$(id -u)" = 0 ]; then
    echo "######################################################################"
    echo "This script should NOT be run as root user as it may create unexpected"
    echo " problems and you may have to reinstall Arch. So run this script as a "
    echo "  normal user. You will be asked for a sudo password when necessary   "
    echo "######################################################################"
    exit 1
fi


sudo cp sources.list /etc/apt/
sudo apt update
sudo apt upgrade
sudo apt purge -y $(cat rpkg)
sudo apt -y autopurge

echo ""
read -r -p "Do you want to install AMD/ATI drivers? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sudo apt install -y firmware-amd-graphics libgl1-mesa-dri libglx-mesa0 mesa-vulkan-drivers xserver-xorg-video-all
fi

echo ""
read -r -p "Do you want to install Nvidia drivers(Maxwell+)? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sudo apt install -y linux-headers-amd64
    sudo apt install -y nvidia-detect nvidia-driver firmware-misc-nonfree nvidia-suspend-common
    echo 'GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX nvidia-drm.modeset=1"' | sudo tee /etc/default/grub.d/nvidia-modeset.cfg > /dev/null
    sudo update-grub
    sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service
    echo 'options nvidia NVreg_PreserveVideoMemoryAllocations=1' | sudo tee /etc/modprobe.d/nvidia-power-management.conf > /dev/null
fi

sudo apt install -y $(cat tpkg)
echo ""
sudo smbpasswd -a $(whoami)
echo ""
sudo ufw enable
sudo ufw allow CUPS
sudo ufw allow CIFS
sudo ufw allow Samba
sudo ufw allow OpenSSH
sudo cupsctl
pipx ensurepath
chsh -s /usr/bin/fish
sudo chsh -s /usr/bin/fish
echo -e "VISUAL=nvim\nEDITOR=nvim" | sudo tee /etc/environment > /dev/null
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo ""
read -r -p "Do you want to create a Samba Shared folder? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "[Samba Share]\ncomment = Samba Share\npath = /home/$(whoami)/Samba Share\nwritable = yes\nguest ok = no" | sudo tee -a /etc/samba/smb.conf > /dev/null
    mkdir -p ~/Samba\ Share
    sudo systemctl restart smbd
fi

echo ""
echo "Installing XFCE..."
echo ""
sudo apt install -y $(cat xfce)
xfconf-query -c xfwm4 -p /general/button_layout -n -t string -s "|HMC"
xfconf-query -c xfwm4 -p /general/raise_with_any_button -n -t bool -s false
xfconf-query -c xfwm4 -p /general/mousewheel_rollup -n -t bool -s false
xfconf-query -c xfwm4 -p /general/scroll_workspaces -n -t bool -s false
xfconf-query -c xfwm4 -p /general/placement_ratio -n -t int -s 100
xfconf-query -c xfwm4 -p /general/show_popup_shadow -n -t bool -s true
xfconf-query -c xfwm4 -p /general/wrap_windows -n -t bool -s false
xfconf-query -c xfce4-panel -p /panels -n -t int -s 1 -a
xfconf-query -c xfce4-panel -p /panels/panel-1/size -n -t int -s 32
xfconf-query -c xfce4-panel -p /panels/panel-1/icon-size -n -t int -s 16
xfconf-query -c xfce4-panel -p /plugins/plugin-1/show-button-title -n -t bool -s false
xfconf-query -c xfce4-panel -p /plugins/plugin-1/button-icon -n -t string -s "desktop-environment-xfce"
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -n -t bool -s false
xfconf-query -c xfce4-notifyd -p  /do-slideout -n -t bool -s true
xfconf-query -c xfce4-notifyd -p  /notify-location -n -t int -s 3
xfconf-query -c xfce4-notifyd -p  /expire-timeout -n -t int -s 5
xfconf-query -c xfce4-notifyd -p  /initial-opacity -n -t double -s 1
sudo sed -i 's/^#greeter-setup-script=.*/greeter-setup-script=\/usr\/bin\/numlockx on/' /etc/lightdm/lightdm.conf
sudo cp lightdm-gtk-greeter.conf /etc/lightdm/

echo ""
read -r -p "Do you want to install Papirus Icon Theme and Colloid GTK Theme? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    wget -qO- https://git.io/papirus-icon-theme-install | sh

    git clone https://github.com/vinceliuice/Colloid-gtk-theme.git --depth=1
    cd Colloid-gtk-theme/
    sudo ./install.sh
    cd ..
    rm -rf Colloid-gtk-theme/

    xfconf-query -c xsettings -p /Net/IconThemeName -n -t string -s "Papirus-Dark"
    xfconf-query -c xsettings -p /Net/ThemeName -n -t string -s "Colloid-Dark"
    xfconf-query -c xfwm4 -p /general/theme -n -t string -s "Colloid-Dark"
fi

echo ""
read -r -p "Do you want to configure git? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    read -p "Enter your Git name: " git_name
    read -p "Enter your Git email: " git_email
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    ssh-keygen -t ed25519 -C "$git_email"
    git config --global gpg.format ssh
    git config --global user.signingkey /home/$(whoami)/.ssh/id_ed25519.pub
    git config --global commit.gpgsign true
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
    sudo apt update
    sudo apt install -y cloudflare-warp
fi

cp QtProject.conf ~/.config/
sudo cp 30-touchpad.conf /etc/X11/xorg.conf.d/

echo ""
read -r -p "Do you want to reboot (recommended)? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sudo systemctl reboot
fi
