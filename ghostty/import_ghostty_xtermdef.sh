#!/bin/bash

<<comment
#		██╗███████╗███████╗███╗   ██╗███████╗ ██████╗ ███████╗████████╗
#		██║██╔════╝██╔════╝████╗  ██║██╔════╝██╔═══██╗██╔════╝╚══██╔══╝
#		██║███████╗█████╗  ██╔██╗ ██║███████╗██║   ██║█████╗     ██║
#		██║╚════██║██╔══╝  ██║╚██╗██║╚════██║██║   ██║██╔══╝     ██║
#		██║███████║███████╗██║ ╚████║███████║╚██████╔╝██║        ██║
#		╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝        ╚═╝
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#

Stuff to do:
- host files
- determine whether tic is local or system wide (requiring sudo)
	- check if already sudo
	- if not sudo, ask if user wants import system wide or just for user
	- if sudo, ask whether they meant to run as sudo
		- if yes, continue, else display error and exit
- use tic command to import xterm definition

comment

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
#---> Colored coded message functions with timestamps
info() { echo -e "${BLUE}[INFO]${NC} [$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
input() { echo -e "${CYAN}[INPUT]${NC} [$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} [$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} [$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2; }
error() { echo -e "${RED}[ERROR]${NC} [$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2; }
debug() { [[ -n "${DEBUG:-}" ]] && echo -e "${PURPLE}[DEBUG]${NC} [$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2; }
fatal() { echo -e "${RED}${BOLD}[FATAL]${NC} [$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2; exit 1; }

#---> Help function for script usage
usage() {
    echo "Usage: $0 [-u|--ghusername GITHUB_USERNAME]"
    echo "Options:"
    echo "  -u, --ghusername    Set GitHub username"
    echo "  -h, --help          Display this help message"
}

get_sudo () {
    info "Gathering sudo for system wide xtern definition import..."

    #---> Can you even sudo?
    if ! sudo -l &>/dev/null; then
        fatal "User does not have sudo privileges. Exiting script..."
    fi

    #---> Prompt for password if sudo is possible
    if ! sudo -v; then
        fatal "Unable to acquire sudo credentials. Exiting script..."
    fi

    success "Sudo acquired successfully... Moving on!"
}




#######################################
# Main Script Block ###################
#######################################

#---> Acquire sudo for needed escalations
get_sudo
