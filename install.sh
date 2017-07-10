#!/bin/bash
# James' UNIX System Setup

# Why this script asks for sudo:
# - To change your shell
# - To install Homebrew (Mac)

# Setup Variables
LINKDIR=$HOME # Not sure if this and the next line are the best way of doing this
DOTDIR="$LINKDIR/.dotfiles" # but I'll go with it for now
EXIST_DOT_BACKUP="$LINKDIR/.jsetup_backups"
BACKUP_ALL=false
SKIP_ALL=false

# Helper functions
info () { printf "\r  [ \033[00;34m..\033[0m ] $1\n"; } 			# [ .. ] $1
user () { printf "\r  [ \033[0;33m??\033[0m ] $1\n"; } 				# [ ?? ] $1
alert () { printf "\r  [ \033[0;91m!!\033[0m ] $1\n"; } 			# [ !! ] $1
success () { printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"; } 	# [ OK ] $1
fail () { printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"; exit; } # [FAIL] $1
mkcd () { mkdir -p $1; cd $1; }

# Environment Setup
install_dotfiles() {
	# $0 to ignore this running file
	local IGNORE=("install.sh" ".git" ".gitignore" ".gitmodules" "README.md" ".DS_Store" "dot_macos")
	
	dir_to_link=$DOTDIR
	if [ $1 ]; then
		local abs_dir=$(cd $1; pwd)	
		dir_to_link="$abs_dir"
	fi
	
	for file_abs in $(find $dir_to_link -mindepth 1 -maxdepth 1 | sort) # For every file in $dir_to_link
	do
		file=$(basename $file_abs)
		if [[ "${IGNORE[@]}" =~ "$file" ]]; then continue; fi # Continue if it's being ignored
		dotlink="$LINKDIR/.$file" # Create intended file link location

		if [[ -e $dotlink ]]; then # Check if file/folder already exists
			# Here, we check if $dotlink is a symbolic file, and if the link location is the same as a file in our $dir_to_link directory.
			# If all is true, the continue, because it's already linked.
			if [[ -L $dotlink && "$(readlink $dotlink)" == "$dir_to_link/$file" ]]; then info "$file already linked..."; continue; fi

			if [[ "$SKIP_ALL" == true ]]; then alert "Skipping $file"; continue; fi 	# Uphold skip all
			if [[ "$BACKUP_ALL" == false ]]; then										# Skip query and go straight to backup
	 			user "$(basename $dotlink) already exists in $LINKDIR. [B]ackup, Backup [a]ll (to $(basename $EXIST_DOT_BACKUP), [s]kip, or ski[p] all?"
				read -n 1 action 																		# Take action.
				if [[ $action == "a" ]]; then BACKUP_ALL=true; fi 										# Activate the backup all
				if [[ $action == "p" ]]; then SKIP_ALL=true; fi 										# Activate the skip all
				if [[ $action == "s" || $action == "p" ]]; then alert "Skipping $file"; continue; fi 	# Make/use backup and continue
			fi
			mkdir -p $EXIST_DOT_BACKUP 													# Ensure backup dir exists...
			mv "$dotlink" "$EXIST_DOT_BACKUP/.${file}_$(date +%Y-%m-%d:%H:%M:%S)"		# Move $dotlink to backup dir...
			success "Original $(basename $dotlink) backed-up!"							# Logging to user
		fi
		ln -s "$file_abs" "$dotlink" 	# Link the files!
		success "$file linked!" 		# Alert of link
	done
	success "Linked $dir_to_link files!" 
}

# OSX Setup Functions
install_homebrew() {
	if [[ "$(which brew)" == "1" ]]; then
		info "Installing Homebrew..."
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	else
		info "Homebrew already installed. Updating..."
		brew update &> /dev/null
	fi
	#TODO: Is this necessary?
	if [[ "$(brew tap)" == *"caskroom/cask"* ]]; then
		info "Homebrew cask already installed. Skipping..."
	else
		info "Installing Homebrew Cask..."
		brew tap caskroom/cask
	fi
	success "Homebrew installation complete!"
}
install_mac_apps() {
	info "Installing Cask application..."
	local APPS=("google-chrome" "discord" "iterm2" "transmission" "skype" "steam" "ubersicht")

	for app in ${APPS[@]}; do
		info "Installing $app..."; brew cask install "$app" &>/dev/null
	done

	success "Installed Brew Cask Applications!"
	exit
}

# ArchLinux Specific
# TODO: Consider if makepkg lines should be supressed

install_pacman() {
	if [[ -z $(pacman -Qs $1) ]]; then
		info "Installing $1..."
		sudo pacman --noconfirm --needed -S $1 &>/dev/null
	else
		alert "$1 already installed. Skipping..."
	fi
}

install_pacaur(){
	if [[ -z $(pacman -Qs $1) ]]; then
		info "Installing $1 via pacaur..."
		pacaur --noconfirm --needed --noedit -S $1 &>/dev/null
	else
		alert "$1 already installed. Skipping..."
	fi
}

install_aur_git () {
	if [[ -z $(pacman -Qs $1) ]]; then
		info "Installing $1..."
		git clone --quiet https://aur.archlinux.org/$1.git
		cd $1
		makepkg --skippgpcheck --install --needed --noconfirm &>/dev/null
	else
		alert "$1 already installed. Skipping..."
	fi
}

install_aur_helper() {
	local work_dir="$(mktemp -d)"
	cd $work_dir
	info "Installing Pacaur..."
	info "Using working directory $work_dir..."
	info "Installing pacaur dependencies..."
	install_pacman expac
	install_pacman yajl
	install_pacman git
	install_aur_git cower; cd $work_dir
	install_aur_git pacaur;

	info "Deleting working directory..."
	rm -rf $work_dir
	success "Installed AUR Helper!"
}

install_x11(){
	info "Installing X11 Display server..."
	install_pacman xorg-server
	install_pacman xorg-xinit
	install_pacman xorg-xrandr
	install_pacman feh # Not apart of the server... but best category
	success "Installed X11 Display Server!"
}

install_fonts(){
	# Note on fonts: To see the system font name, use fc-list
	info "Installing fonts..."
	install_pacman ttf-hack
	install_pacman ttf-inconsolata
	install_pacman adobe-source-code-pro-fonts
	install_pacaur otf-san-francisco
	success "Installed fonts!"
}

install_arch_programs(){
	install_pacman zsh
	install_pacman rxvt-unicode
	install_pacman vim

	info "Changing shell to zsh..."
	chsh -s $(which zsh)
}

# START OF SCRIPT
sudo -v

# Linking dotfililes
info "Linking universal dotfiles..."
install_dotfiles dot_uni

# OS Spexific actions
if [[ "$(uname)" == "Darwin" ]]; then # If we're using OSX/macOS
	# Add Darwin specific dotifles	
	info "Linking Darwin dotfiles..."
	install_dotfiles ./dot_macos
	exit # Temporary
	# Create Applications folder in home
	mkdir -p ~/Applications

	# TODO: Check if XcodeCLT  is already installed
	# Install Xcode Command line tools
	info "Installing command line tools..."
	xcode-select --install &> /dev/null

	install_homebrew
	install_mac_apps

elif [[ -f /etc/arch-release ]]; then # If we're using ArchLinux
	info "Updating arch system..."
	sudo pacman -Syu --noconfirm &>/dev/null

	info "Linking Arch dotfiles..."
	install_dotfiles ./dot_arch

	install_aur_helper
	install_x11
	install_fonts
	install_arch_programs
elif [[ -f /etc/debian_version ]]; then # If we're using Ubuntu/Debian
	:
fi
