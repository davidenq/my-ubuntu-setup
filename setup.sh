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
    ubuntu-restricted-extras \
    net-tools \
    openssh-server \
    fuse \
    libfuse2 \
    gnome-keyring

  git config --global init.defaultBranch main
}

remove_snap() {
  sudo systemctl stop snapd
  sudo apt remove --purge --assume-yes snapd gnome-software-plugin-snap
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

install_krita() {
  sudo apt install krita
}

install_postman() {
  curl https://dl.pstmn.io/download/latest/linux64 --output /tmp/postmain.tar.gz
  sudo tar -xvf /tmp/postmain.tar.gz -C /opt
  touch ~/.local/share/applications/Postman.desktop
  printf "
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Exec=/opt/Postman/app/Postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
" >>~/.local/share/applications/Postman.desktop
}

install_ngrok() {
  curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
  echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
  sudo apt update
  sudo apt install ngrok
}

install_docker_compose() {
  sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
}

install_aws_cli() {
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  rm -rf ./awscliv2.zip ./aws
}

install_inkscape() {
  sudo add-apt-repository ppa:inkscape.dev/stable
  sudo apt update
  sudo apt install -y inkscape
}

install_brave() {
  sudo apt install apt-transport-https curl
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt update
  sudo apt install brave-browser
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
install_krita
install_aws_cli
install_brave
