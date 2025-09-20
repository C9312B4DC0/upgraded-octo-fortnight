#!/bin/bash





#######################################
# Variables ###########################
#######################################

#---> Text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'

# Credits

#---> SOME EXPLAINER STUFF
# Note: I used some Claude Opus 4 to explain some of my options and what they do and to help better understand how to best lay out the script.

#######################################
# Functions ###########################
#######################################

#---> Determine package manager for install
function set_packagemanager() {
    if command -v apt &> /dev/null; then
		echo -e "${GREEN}Package manager is apt."
        pkg_install() { sudo apt install -y "$@"; }
        pkg_update()  { sudo apt update -y; }
        pkg_remove()  { sudo apt remove -y "$@"; }
        pkg_search()  { apt search "$@"; }

    elif command -v dnf &> /dev/null; then
		echo "${GREEN}Package manager is dnf."
        pkg_install() { sudo dnf install -y "$@"; }
        pkg_update()  { sudo dnf update -y; }
        pkg_remove()  { sudo dnf remove -y "$@"; }
        pkg_search()  { dnf search "$@"; }

	elif command -v yum &> /dev/null; then
		echo "${GREEN}Package manager is yum."
        pkg_install() { sudo yum -y install "$@"; }
        pkg_update()  { sudo yum -y update; }
        pkg_remove()  { sudo yum -y remove "$@"; }
        pkg_search()  { yum info "$@"; }

    elif command -v pacman &> /dev/null; then
		echo "${GREEN}Package manager is pacman."
        pkg_install() { sudo pacman -S --noconfirm "$@"; }
        pkg_update()  { sudo pacman -Sy; }
        pkg_remove()  { sudo pacman -R --noconfirm "$@"; }
        pkg_search()  { pacman -Ss "$@"; }

	else
		echo "${RED}No supported package manager found! Exiting script!" >&2 # stderr out (learned something new!)
		return 1
	fi
}


#######################################
# Main Block ##########################
#######################################
echo "${YELLOW}Determining package manager for OS..."
set_packagemanager #---> Determine and set package manager

echo "${YELLOW}Updating system packages before installing apps..."
pkg_update #---> Update system
echo "${GREEN}System packages updated!"

echo "${YELLOW}Installing python3-pip..."
#---> Install PIP
#---> Import keys as non root user!
#---> Backup ssh config
#---> Configure SSH security
#---> Restart sshd
#---> Install Fail2Ban and enable service
#---> Configure Fail2Ban
#---> Test access