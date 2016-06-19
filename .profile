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
PYTHON_VERSION="2.7.11"

# Ruby variables
RUBY_BASE=$LOCAL_DIR/ruby
RUBY_ACTIVE=$RUBY_BASE/current
RUBY_BIN=$RUBY_ACTIVE/bin
RUBY_LIB=$RUBY_ACTIVE/lib
RUBY_VERSION="2.3.1"

# Java variables
JAVA_BASE=$LOCAL_OPT/java
JAVA_HOME=$JAVA_BASE/current
JAVA_BIN=$JAVA_HOME/bin
JDK_HOME=$JAVA_BASE/current

BASE_16_PATH=$HOME/.config/base16-shell
BASE16_THEME="eighties"
BASE16_STYLE="dark"

# tmxinator settings
EDITOR='vim'
DISABLE_AUTO_TITLE=true

PATH=$LOCAL_BIN:$PYTHON_BIN:$RUBY_BIN:$JAVA_BIN:$BASE_16_PATH:$PATH
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

# Install Python if needed.
if [[ ! -e $PYTHON_BIN/python ]]; then
  install_python $PYTHON_VERSION
fi

# Install Ruby if needed.
if [[ ! -e $RUBY_BIN/ruby ]]; then
  install_ruby $RUBY_VERSION
fi

# Install these if needed.
install_base16
install_powerline_fonts
install_misc_tools
install_tmuxinator
install_NeoBundle
install_oh_my_zsh

# If docker-machine is setup, make sure we
# setup our enviroment for that.
if [[ `command -v docker-machine` && `docker-machine status docker` == "Running" ]]; then
  eval "$(docker-machine env docker)"
fi

# Change term from light to dark
alias light="source $BASE_16_PATH/base16-$BASE16_THEME.light.sh"
alias dark="source $BASE_16_PATH/base16-$BASE16_THEME.dark.sh"

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
else
  # On linux/unix use this conf for tmux
  cp ~/.tmux_linux.conf ~/.tmux.conf
fi

# Execute Base 16 Shell
BASE16_SHELL="$BASE_16_PATH/base16-$BASE16_THEME.$BASE_16_STYLE.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

source $LOCAL_BIN/tmuxinator.zsh

echo "Profile Loaded"