# Create top of script
# Determine OS, set flag
# Install python, import app, import GitHub keys
# Configure sshd config


## Some test code...
echo "Hello world!"

# Credits

#---> SOME EXPLAINER STUFF
# Note: I used some Claude Opus 4 to explain some of my options and what they do and to help better understand how to best lay out the script.


#---> Determine package manager for install
# function set_packagemanager ()

function set_packagemanager() {
    if command -v apt &> /dev/null; then
        pkg_install() { sudo apt install -y "$@"; }
        pkg_update()  { sudo apt update -y; }
        pkg_remove()  { sudo apt remove -y "$@"; }
        pkg_search()  { apt search "$@"; }

    elif command -v dnf &> /dev/null; then
        pkg_install() { sudo dnf install -y "$@"; }
        pkg_update()  { sudo dnf update -y; }
        pkg_remove()  { sudo dnf remove -y "$@"; }
        pkg_search()  { dnf search "$@"; }

	elif command -v yum &> /dev/null; then
        pkg_install() { sudo yum -y install "$@"; }
        pkg_update()  { sudo yum -y update; }
        pkg_remove()  { sudo yum -y remove "$@"; }
        pkg_search()  { yum info "$@"; }

    elif command -v pacman &> /dev/null; then
        pkg_install() { sudo pacman -S --noconfirm "$@"; }
        pkg_update()  { sudo pacman -Sy; }
        pkg_remove()  { sudo pacman -R --noconfirm "$@"; }
        pkg_search()  { pacman -Ss "$@"; }

	else
		echo "No supported package manager found!" >&2 # stderr out (learned something new!)
		return 1
	fi
}

pkg_update