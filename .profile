PATH=~/local/bin:$PATH
PATH=~/local/jruby/current/bin:$PATH
PATH=~/local/opt/java/current/bin:$PATH
PYTHON_BASE=~/local/python
PYTHON_HOME=~/local/python/current
RUBY_BASE=~/local/ruby
RUBY_HOME=~/local/ruby/current
GOROOT=~/local/go
GOPATH=~/projects/go-projects
INTELLIJ_HOME=~/local/opt/IntelliJ14
JAVA_HOME=~/local/opt/java/current
JDK_HOME=~/local/opt/java/current
ECLIPSE_HOME=~/local/opt/eclipse
BASE_16_PATH=~/.config/base16-shell
EC2_HOME=~/local/ec28
PYTHONSTARTUP=~/.pythonrc
# tmxinator settings
export EDITOR='vim'
export DISABLE_AUTO_TITLE=true

PATH="$BASE_16_PATH:$GOROOT/bin:$INTELLIJ_HOME/bin:$ECLIPSE_HOME:$RUBY_HOME/bin:$EC2_HOME/bin:$PYTHON_HOME/bin:$PATH"
export PS1 PATH JAVA_HOME JDK_HOME ECLIPSE_HOME INTELLIJ_HOME GOROOT GOPATH EC2_HOME RUBY_BASE RUBY_HOME CLICOLOR LSCOLORS PYTHONSTARTUP PYTHON_BASE PYTHON_HOME

# Create config directory for dotfiles if needed
if [[ ! -d ~/.config/dotfiles ]]; then
  mkdir -p ~/.config/dotfiles
fi

# Install powerline patched fonts if needed
if [[ ! -f ~/.config/dotfiles/powerline_fonts ]]; then
  echo "Installing patched powerline fonts"
  mkdir -p ~/local/src
  cd ~/local/src/
  git clone https://github.com/powerline/fonts.git
  cd fonts
  ./install.sh && touch ~/.config/dotfiles/powerline_fonts
  cd ~
fi


if [[ $OSTYPE == darwin* ]]; then 
  # on OSX enable color coding on files, 
  # the LSCOLORS attempts to match default Linux bash shell
  CLICOLOR=1
  LSCOLORS=ExFxCxDxBxegedabagacad
  
  # Install reattach-to-user-namespace if needed
  if [[ ! `command -v reattach-to-user-namespace` ]]; then
    echo "Installing tmux-MacOSX-pasteboard"
    brew install reattach-to-user-namespace
  fi

  # Install silver searcher if needed
  if [[ ! `command -v ag` ]]; then
    echo "Installing the silver searcher"
    brew install ag
  fi
fi

# Install Base-16 Shell themes if needed
if [ ! -d "$BASE_16_PATH" ]; then
  echo "Installing Base 16 Shell"
  git clone https://github.com/chriskempson/base16-shell.git $BASE_16_PATH
fi

# Install Isort if needed
if [[ ! `command -v isort` ]]; then
  echo "Installing Isort"
  pip install isort
fi

# Install grip if needed
if [[ ! `command -v grip` ]]; then
  echo "Installing grip"
  pip install grip
fi

# Install tmuxinator if needed
if [[ ! `command -v tmuxinator` ]]; then
  echo "Installing tmuxinator"
  gem install tmuxinator
fi

# Install oh-my-zsh if needed
if [[ ! -d ~/.oh-my-zsh ]]; then
  echo "Installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

# Execute Base 16 Shell
BASE16_THEME="eighties"
BASE16_SHELL="$BASE_16_PATH/base16-$BASE16_THEME.dark.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

# Custom functions and aliases

if [[ $OSTYPE == darwin*  && `command -v docker-machine` && `docker-machine status docker` == "Running" ]]; then
  eval "$(docker-machine env docker)"
fi

# Change term from light to dark
alias light="source $BASE_16_PATH/base16-$BASE16_THEME.light.sh"
alias dark="source $BASE_16_PATH/base16-$BASE16_THEME.dark.sh"

switch_ruby () {
  if [ -z "$1" ]; then
    echo "Usage switch_ruby [version number]";
  else
    version=$1
    if [ -d $RUBY_BASE ]; then
      mkdir -p $RUBY_BASE;
    fi
    if [ -d "$RUBY_BASE/v$version" ]; then
      if [ -e "$RUBY_BASE/current" ]; then
        rm "$RUBY_BASE/current"
      fi
      ln -s `echo "$RUBY_BASE/v$version $RUBY_BASE/current"`;
      echo "Switched to $version | `ruby -v`";
    else
      echo "Ruby $version is not installed"
      # Todo offer install option
    fi
  fi
}


function install_NeoBundle(){
if [ ! -e ~/.vim/bundle/neobundle.vim/bin/neoinstall ]; then
  echo "Installing NeoBundle"
  curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh
fi
}

# Godaddy VPN
vpn(){
  if [ -z $1 ]; then
    echo -n "Pin: "
    read -s pin
  else
    pin=$1
  fi
  scutil --nc start "GoDaddy Corp VPN"
  password=`echo $pin|stoken|grep '^\d'|tr -d '\n'`
  sleep 2
  osascript -e "tell application \"System Events\" to keystroke \"$password\""
  osascript -e "tell application \"System Events\" to keystroke return"
}

install_NeoBundle
source ~/local/bin/tmuxinator.zsh

if [[ -f ~/aliases.sh ]]; then
  echo "Loading aliases file"
  source ~/aliases.sh
fi

echo "Profile Loaded"
