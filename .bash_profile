PATH=~/local/bin:$PATH
PATH=~/local/jruby/current/bin:$PATH
PATH=~/local/opt/java/current/bin:$PATH
RUBY_BASE=~/local/ruby
RUBY_HOME=~/local/ruby/current
GOROOT=~/local/go
GOPATH=~/Projects
INTELLIJ_HOME=~/local/opt/IntelliJ14
JAVA_HOME=~/local/opt/java/current
JDK_HOME=~/local/opt/java/current
ECLIPSE_HOME=~/local/opt/eclipse
BASE_16_PATH=~/.config/base16-shell
EC2_HOME=~/local/ec2

# Per user hostaliases
export HOSTALIASES=~/.hosts

if [[ $OSTYPE == darwin* ]]; then 
  # on OSX enable color coding on files, 
  # the LSCOLORS attempts to match default Linux bash shell
  CLICOLOR=1
  LSCOLORS=ExFxCxDxBxegedabagacad
fi

# Install Base-16 Shell themes if needed
if [ ! -d "$BASE_16_PATH" ]; then
  echo "Installing Base 16 Shell"
  git clone https://github.com/chriskempson/base16-shell.git $BASE_16_PATH
fi

PATH="$BASE_16_PATH:$GOROOT/bin:$INTELLIJ_HOME/bin:$ECLIPSE_HOME:$RUBY_HOME/bin:$EC2_HOME/bin:$PATH"
export PATH JAVA_HOME JDK_HOME ECLIPSE_HOME INTELLIJ_HOME GOROOT GOPATH EC2_HOME RUBY_BASE RUBY_HOME CLICOLOR LSCOLORS


# Execute Base 16 Shell
BASE16_SHELL="$BASE_16_PATH/base16-google.dark.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

# Custom functions and aliases

if [[ $OSTYPE == darwin*  && `boot2docker status` == "running" ]]; then
  $(boot2docker shellinit) 
fi

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


install_NeoBundle

echo "Profile Loaded"
