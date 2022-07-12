export ZSH="$HOME/.oh-my-zsh"
export GOPATH=$HOME/.go
export NPM_PACKAGES="~/.npm_packages"
export PATH="$PATH:$NPM_PACKAGES/bin:$GOPATH/bin:/usr/local/go/bin"
export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"

#command for auto-correction.
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  git
  node
  vscode
  golang
  docker
  aws
  postgres
  dotenv
  rust
  zsh-autosuggestions
  zsh-autocomplete
)
source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
