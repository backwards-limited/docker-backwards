# Setup

Apologies I shall only cover **Mac** - One day I may include Linux and Windows.

Install [Homebrew](https://brew.sh) for easy package management on Mac:

```bash
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Install essentials:

```bash
brew cask install virtualbox
brew cask install minikube
brew install awscli
brew install jq
brew install kubernetes-cli
brew install kubectl
brew install kubernetes-helm
brew tap johanhaleby/kubetail && brew install kubetail
brew install node
brew install httpie
```

Finally install [Docker for Mac](https://www.docker.com/products/docker-desktop).

As a useful extra, we can have CLI completions for Docker. This can be setup for any shell, but specifically for [zsh](https://github.com/robbyrussell/oh-my-zsh/wiki/Installing-ZSH) do the following:

```bash
brew install bash-completion
```

Add the following to your **.zshrc**:

```bash
if [[ -d /Applications/Docker.app ]]; then
	for f in docker docker-compose docker-machine; do
		source /Applications/Docker.app/Contents/Resources/etc/${f}.zsh-completion
		compdef _${f} ${f}
		autoload -U _${f}
	done
fi
```

And **source** said file:

```bash
source ~/.zshrc
```

Extras:

```bash
brew tap homebrew/cask-fonts
brew cask install font-hack-nerd-font
brew install mosh
```
