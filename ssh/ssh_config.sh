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
info() { echo -e "${BLUE}[INFO]${NC} $*"; }
input() { echo -e "${CYAN}[INPUT]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $*" >&2; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
debug() { [[ -n "${DEBUG:-}" ]] && echo -e "${PURPLE}[DEBUG]${NC} $*" >&2; }
fatal() { echo -e "${RED}${BOLD}[FATAL]${NC} $*" >&2; exit 1; }


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
		exit 1
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

#---> Install PIP
info "Installing python3-pip..."
if ! command -v pip &> /dev/null; then
	info "Installing Python PIP..."
	pkg_install python3-pip || fatal "Unable to install PIP, exiting..." #---> Fatal message function exits program... probably shouldn't do that...
else
	success "PIP already installed, moving on!"
fi

#---> Import keys as non root user!
info "Importing GitHub SSH keys..."
read -p "Enter your GitHub username: " gh_username </dev/tty
info "Pulling SSH keys from GitHub as user $gh_username..."

if output=$( ssh-import-id-gh "$gh_username" 2>&1 ); then #---> Captures output and displays as needed...
    success "SSH keys pulled from GitHub! Onward!"
    debug "Output: $output"
else
    error "Command output: $output"
    fatal "Unable to pull keys from GitHub. Did you enter the correct username? Exiting script..."
fi

#---> Backup SSH config
info "Backing up original SSHD config (/etc/ssh/sshd_config)"
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup || fatal "Failed to backup SSH config. Exiting script..."
success "Successfully backed up sshd_config! Backup filename: sshd_config.backup"

#---> Configure SSH security
info "Modifying SSHD config..."
sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config #---> Disable root login
sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config #---> Disable password authentication
sudo sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config #---> Enable public key authentication
sudo sed -i 's/^#*PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config #---> Disable empty passwords
sudo sed -i 's/^#*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config #---> Disable challenge-response authentication
sudo sed -i 's/^#*KerberosAuthentication.*/KerberosAuthentication no/' /etc/ssh/sshd_config #---> Disable Kerberos authentication
sudo sed -i 's/^#*GSSAPIAuthentication.*/GSSAPIAuthentication no/' /etc/ssh/sshd_config #---> Disable GSSAPI authentication
sudo sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' /etc/ssh/sshd_config #---> Set max auth tries
sudo sed -i 's/^#*MaxSessions.*/MaxSessions 10/' /etc/ssh/sshd_config #---> Set max sessions
sudo sed -i 's/^#*ClientAliveInterval.*/ClientAliveInterval 300/' /etc/ssh/sshd_config #---> Set client alive interval
sudo sed -i 's/^#*ClientAliveCountMax.*/ClientAliveCountMax 2/' /etc/ssh/sshd_config #---> Set client alive count max
sudo sed -i 's/^#*LoginGraceTime.*/LoginGraceTime 60/' /etc/ssh/sshd_config #---> Set login grace time
sudo sed -i 's/^#*AllowTcpForwarding.*/AllowTcpForwarding no/' /etc/ssh/sshd_config #---> Disable TCP forwarding
sudo sed -i 's/^#*X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config #---> Disable X11 forwarding
sudo sed -i 's/^#*AllowAgentForwarding.*/AllowAgentForwarding no/' /etc/ssh/sshd_config #---> Disable agent forwarding
sudo sed -i 's/^#*PermitTunnel.*/PermitTunnel no/' /etc/ssh/sshd_config #---> Disable tunnel
sudo sed -i 's/^#*GatewayPorts.*/GatewayPorts no/' /etc/ssh/sshd_config #---> Disable gateway ports
sudo sed -i 's/^#*LogLevel.*/LogLevel VERBOSE/' /etc/ssh/sshd_config #---> Set log level
sudo sed -i 's/^#*UseDNS.*/UseDNS no/' /etc/ssh/sshd_config #---> Disable DNS lookup
sudo sed -i 's/^#*Compression.*/Compression delayed/' /etc/ssh/sshd_config #---> Set compression
sudo sed -i 's/^#*TCPKeepAlive.*/TCPKeepAlive yes/' /etc/ssh/sshd_config #---> Enable TCP keep alive

# Add settings that might not exist (append if not found)
sudo grep -q "^MaxStartups" /etc/ssh/sshd_config || sudo echo "MaxStartups 10:30:60" >> /etc/ssh/sshd_config
sudo grep -q "^AuthenticationMethods" /etc/ssh/sshd_config || sudo echo "AuthenticationMethods publickey" >> /etc/ssh/sshd_config

# Add crypto settings (these are usually not in default config)
sudo grep -q "^Ciphers" /etc/ssh/sshd_config || sudo echo "Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr" >> /etc/ssh/sshd_config
sudo grep -q "^MACs" /etc/ssh/sshd_config || sudo echo "MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com" >> /etc/ssh/sshd_config
sudo grep -q "^KexAlgorithms" /etc/ssh/sshd_config || sudo echo "KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512" >> /etc/ssh/sshd_config

# Test configuration and restart if valid
if sudo sshd -t; then
    echo "SSH configuration valid, restarting service..."
    sudo systemctl restart sshd
    echo "SSH daemon restarted successfully"
else
    echo "SSH configuration test failed, restoring backup..."
    if sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config; then
        info "Restored orginal SSHD config file. Exiting script..."
        exit 1
    else
        fatal "Failed to resture sshd_config! Exiting script..."
    fi
fi




#---> Restart sshd
#---> Install Fail2Ban and enable service
#---> Configure Fail2Ban
#---> Test access