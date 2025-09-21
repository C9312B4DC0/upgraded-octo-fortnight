#!/bin/bash



# Credits

#---> SOME EXPLAINER STUFF
# Note: I used some Claude Opus 4 to explain some of my options and what they do and to help better understand how to best lay out the script.


#######################################
# Variables ###########################
#######################################

#---> Text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color



#######################################
# Functions ###########################
#######################################
#---> Colored message functions
info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" >&2
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

debug() {
    [[ -n "${DEBUG:-}" ]] && echo -e "${PURPLE}[DEBUG]${NC} $*" >&2
}

fatal() {
    echo -e "${RED}${BOLD}[FATAL]${NC} $*" >&2
    exit 1
}


#---> Determine package manager for install
function set_packagemanager() {
    if command -v apt &> /dev/null; then
		success "Package manager is apt."
        pkg_install() { sudo apt install -y "$@"; }
        pkg_update()  { sudo apt update -y; }
        pkg_remove()  { sudo apt remove -y "$@"; }
        pkg_search()  { apt search "$@"; }

    elif command -v dnf &> /dev/null; then
		success "Package manager is dnf."
        pkg_install() { sudo dnf install -y "$@"; }
        pkg_update()  { sudo dnf update -y; }
        pkg_remove()  { sudo dnf remove -y "$@"; }
        pkg_search()  { dnf search "$@"; }

	elif command -v yum &> /dev/null; then
		success "Package manager is yum."
        pkg_install() { sudo yum -y install "$@"; }
        pkg_update()  { sudo yum -y update; }
        pkg_remove()  { sudo yum -y remove "$@"; }
        pkg_search()  { yum info "$@"; }

    elif command -v pacman &> /dev/null; then
		success "Package manager is pacman."
        pkg_install() { sudo pacman -S --noconfirm "$@"; }
        pkg_update()  { sudo pacman -Sy; }
        pkg_remove()  { sudo pacman -R --noconfirm "$@"; }
        pkg_search()  { pacman -Ss "$@"; }

	else
		fatal "No supported package manager found! Exiting script!"
		return 1
	fi
}



#######################################
# Main Script Block ###################
#######################################
info "Determining package manager for OS..."
set_packagemanager #---> Determine and set package manager

info "Updating system packages before installing apps..."
pkg_update #---> Update system
success "System packages updated!"

info "Installing python3-pip..."
#---> Install PIP
#---> Import keys as non root user!
#---> Backup ssh config
#---> Configure SSH security
#---> Restart sshd
#---> Install Fail2Ban and enable service
#---> Configure Fail2Ban
#---> Test access