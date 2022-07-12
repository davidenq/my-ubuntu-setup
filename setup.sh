#!/bin/bash

set -o allexport
source .env set
set +o allexport

set_mirror_apt() {
  sudo sed -i 's|http://ec.|http://|g' /etc/apt/sources.list
  sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y
}

install_ubuntu_dependencies() {
  sudo apt install -y \
    ca-certificates \
    software-properties-common \
    apt-transport-https \
    curl \
    gnupg \
    lsb-release \
    vim \
    zsh \
    wget \
    make \
    git \
    ubuntu-restricted-extras

  git config --global init.defaultBranch main
}

remove_snap() {
  sudo systemctl stop snapd
  sudo apt remove --purge --assume-yes snapd gnome-software-plugin-snap
}

setting_interface() {
  # setting dock
  gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
  gsettings set org.gnome.shell.ubuntu color-scheme 'prefer-dark'
  gsettings set org.gnome.nautilus.icon-view default-zoom-level small

  #fonts
  gsettings set org.gnome.desktop.interface font-name 'Ubuntu 9'
  gsettings set org.gnome.desktop.interface document-font-name 'Sans Regular 9'
  gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 11'
  gsettings set org.gnome.nautilus.desktop font 'Ubuntu 9'
  gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Ubuntu Bold 9'

  #date
  gsettings set org.gnome.desktop.interface clock-show-weekday true
  gsettings set org.gnome.desktop.interface clock-show-date true
  gsettings set org.gnome.desktop.interface clock-show-seconds true

  gsettings set org.gnome.mutter center-new-windows true

  #dock
  gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 22
  gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'RIGHT'
}

install_docker() {
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  sudo usermod -a -G docker $USER
}

install_nodejs() {
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt install -y nodejs
  mkdir ~/.npm_packages
  npm config set prefix "~/.npm_packages"
}

install_golang() {
  sudo apt install golang -y
  mkdir ~/.go
}

install_oh_my_zsh() {
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  mkdir ~/.local/share/fonts
  curl https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -o ~/.local/share/fonts
  curl https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf -o ~/.local/share/fonts
  curl https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf -o ~/.local/share/fonts
  curl https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf -o ~/.local/share/fonts
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete
  sudo fc-cache -f -v
  mv ./templates/* ~/
}

install_google_chrome() {
  curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb --output google-chrome.deb
  sudo dpkg -i google-chrome.deb
  rm -rf google-chrome.deb
}

install_vscode() {
  wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
  sudo add-apt-repository -y "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
  sudo apt install -y code
}

install_spotify() {
  curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | sudo apt-key add -
  echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
  sudo apt-get update && sudo apt-get install -y spotify-client

  spotify --username=$SPOTIFY_USERNAME --password=$SPOTIFY_PASSWORD
}

install_pulseeffets() {
  sudo apt install pulseeffects
  pulseeffects -l ./templates/equalizer.json
}

install_github_cli() {
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt update && sudo apt install -y gh
  ssh-keygen -t ed25519 -C $EMAIL -f $HOME/.ssh/id_ed25519 -N $PASSPHRASE
  gh auth login -p ssh -h github.com -w
}

install_dbeaver() {
  echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
  curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/dbeaver.gpg
  sudo apt update && sudo apt install -y dbeaver-ce
}

set_mirror_apt
install_ubuntu_dependencies
remove_snap
setting_interface
install_docker
install_nodejs
install_golang
install_oh_my_zsh
install_google_chrome
install_vscode
install_spotify
install_pulseeffets
install_github_cli
install_dbeaver
