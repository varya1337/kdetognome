#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root. Please use sudo or log in as root user."
  exit 1
fi

echo "Welcome to the Desktop Environment Switch Script!"
echo "This script will help you remove KDE and install GNOME on your system."
echo "Please note that this operation is at your own risk."

detect_package_manager() {
  local available_package_managers=("apt" "yum" "dnf" "pacman")
  local default_package_manager="apt"

  for manager in "${available_package_managers[@]}"; do
    if command -v "$manager" &> /dev/null; then
      default_package_manager="$manager"
      break
    fi
  done

  echo "$default_package_manager"
}

remove_kde() {
  local package_manager=$1

  case $package_manager in
    "apt")
      apt purge kde-* -y
      apt autoremove -y
      apt clean
      ;;
    "yum"|"dnf")
      yum groupremove "KDE Plasma Workspaces" -y
      ;;
    "pacman")
      pacman -Rns $(pacman -Qsq kde) --noconfirm
      ;;
  esac
}

install_gnome() {
  local package_manager=$1

  case $package_manager in
    "apt")
      apt update
      apt install gnome-shell gnome-terminal -y
      ;;
    "yum"|"dnf")
      yum groupinstall "GNOME Desktop" -y
      ;;
    "pacman")
      pacman -S gnome gnome-terminal --noconfirm
      ;;
  esac
}

user_package_manager=$(detect_package_manager)

echo "Selected Package Manager: $user_package_manager"

remove_kde "$user_package_manager"

install_gnome "$user_package_manager"

echo "Rebooting..."
reboot
