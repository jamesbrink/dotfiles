LOCAL_DIR=$HOME/local
LOCAL_BIN=$LOCAL_DIR/bin
LOCAL_LIB=$LOCAL_DIR/lib
LOCAL_OPT=$LOCAL_DIR/opt
LOCAL_SRC=$LOCAL_DIR/src

# Python variables
PYTHON_BASE=$LOCAL_DIR/python
PYTHON_ACTIVE=$PYTHON_BASE/current
PYTHON_BIN=$PYTHON_ACTIVE/bin
PYTHON_LIB=$PYTHON_ACTIVE/lib
PYTHONSTARTUP=$HOME/.pythonrc
PYTHON_VERSION="2.7.13"

# Ruby variables
RUBY_BASE=$LOCAL_DIR/ruby
RUBY_ACTIVE=$RUBY_BASE/current
RUBY_BIN=$RUBY_ACTIVE/bin
RUBY_LIB=$RUBY_ACTIVE/lib
RUBY_VERSION="2.4.1"

# Java variables
JAVA_BASE=$LOCAL_OPT/java
JAVA_HOME=$JAVA_BASE/current
JAVA_BIN=$JAVA_HOME/bin
JDK_HOME=$JAVA_BASE/current

BASE16_PATH=$HOME/.config/base16-shell
BASE16_THEME="eighties"
BASE16_STYLE="dark"

GO_BASE=$LOCAL_DIR/go
GO_ACTIVE=$GO_BASE/current
GOROOT=$GO_ACTIVE
GO_BIN=$GO_ACTIVE/bin
GO_VERSION="1.6.2"

# tmxinator settings
EDITOR='vim'
DISABLE_AUTO_TITLE=true

PATH=$LOCAL_BIN:$PYTHON_BIN:$RUBY_BIN:$JAVA_BIN:$BASE16_PATH:$GO_BIN:$PATH
LD_LIBRARY_PATH=$LOCAL_LIB:$PYTHON_LIB:$RUBY_LIB

export PATH LD_LIBRARY_PATH
export JAVA_HOME JDK_HOME EDITOR DISABLE_AUTO_TITLE

# Ensure our local directories are created
mkdir -p $LOCAL_BIN $LOCAL_LIB $LOCAL_OPT $LOCAL_SRC $PYTHON_BASE $RUBY_BASE $JAVA_BASE

# Load custom functions
source $HOME/.functions.sh

# Create config directory for dotfiles if needed
if [[ ! -d ~/.config/dotfiles ]]; then
  mkdir -p ~/.config/dotfiles
fi

# If needed install base16 shell
install_base16
# Execute Base 16 Shell
BASE16_SHELL="$BASE16_PATH/base16-$BASE16_THEME.$BASE16_STYLE.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

# Install Python if needed.
if [[ ! -e $PYTHON_BIN/python ]]; then
  if [[ $OSTYPE == darwin* && `command -v python` != "/usr/local/bin/python" ]]; then
    # On OSX use homebrew until I fix build
    # on OSX
    echo "Installing Python from homebrew."
    brew install python
  elif [[ $OSTYPE != darwin* ]]; then
    install_python $PYTHON_VERSION
  fi
fi

# Install Ruby if needed.
if [[ ! -e $RUBY_BIN/ruby ]]; then
  install_ruby $RUBY_VERSION
fi

# Install Go if needed.
if [[ ! -e $GO_BIN/go ]]; then
  install_go $GO_VERSION
fi

# Install these if needed.
install_powerline_fonts
install_misc_tools
install_tmuxinator
install_NeoBundle
install_oh_my_zsh

# If docker-machine is setup, make sure we
# setup our enviroment for that.
if [[ `command -v docker-machine` && `docker-machine status docker 2> /dev/null` == "Running" ]]; then
  eval "$(docker-machine env docker)"
fi

# Change term from light to dark
alias light="base16 light"
alias dark="base16 dark"

# Godaddy VPN
function vpn(){
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

if [[ -f ~/aliases.sh ]]; then
  echo "Loading aliases file"
  source ~/aliases.sh
fi

# OSX Specific Stuff
if [[ $OSTYPE == darwin* ]]; then 
  # on OSX enable color coding on files, 
  # the LSCOLORS attempts to match default Linux bash shell
  export CLICOLOR=1
  export LSCOLORS=ExFxCxDxBxegedabagacad
  cp $HOME/.tmux_osx.conf $HOME/.tmux.conf

  # Install homebrew if needed
  if [[ ! `command -v brew` ]]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

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

  # Install Tag-ag if needed.
  if [[ ! `command -v tag` ]]; then
    echo "Installing Tag"
    brew tap aykamko/tag-ag
    brew install tag-ag
  fi
else
  # On linux/unix use this conf for tmux
  cp ~/.tmux_linux.conf ~/.tmux.conf
fi


source $LOCAL_BIN/tmuxinator.zsh

# Enable support for tag
# https://github.com/aykamko/tag
if (( $+commands[tag] )); then
  tag() { command tag "$@"; source ${TAG_ALIAS_FILE:-/tmp/tag_aliases} 2>/dev/null }
  alias ag=tag
fi

echo "Profile Loaded"
