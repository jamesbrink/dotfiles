PATH=~/local/bin:$PATH
PATH=~/local/jruby/current/bin:$PATH
PATH=~/local/opt/java/current/bin:$PATH
GOROOT=~/local/go
GOPATH=~/Projects
INTELLIJ_HOME=~/local/opt/IntelliJ14
JAVA_HOME=~/local/opt/java/current
JDK_HOME=~/local/opt/java/current
ECLIPSE_HOME=~/local/opt/eclipse
BASE_16_PATH=~/.config/base16-shell

# Install Base-16 Shell themes if needed
if [ ! -d "$BASE_16_PATH" ]; then
  echo "Installing Base 16 Shell"
  git clone https://github.com/chriskempson/base16-shell.git $BASE_16_PATH
fi

PATH="$BASE_16_PATH:$GOROOT/bin:$INTELLIJ_HOME/bin:$ECLIPSE_HOME:$PATH"
export PATH JAVA_HOME JDK_HOME ECLIPSE_HOME INTELLIJ_HOME GOROOT GOPATH

# Execute Base 16 Shell
BASE16_SHELL="$BASE_16_PATH/base16-google.dark.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL
