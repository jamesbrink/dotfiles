function install_python () {
  if [[ -z $1 ]]; then
    echo "Usage install_python [version number]";
  else
    version=$1
    echo "Installing Python ${version}. from source."
    if [[ ! -e "${LOCAL_SRC}/Python-${version}.tar.xz" ]]; then
      python_url="https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz"
      echo "Could not find local tar file for Python ${version}."
      echo "Downloading ${python_url}."
      curl $python_url > $LOCAL_SRC/Python-$version.tar.xz
    fi
    original_dir=$CWD
    python_dst=$PYTHON_BASE/$version
    cd $LOCAL_SRC
    tar -xf Python-$version.tar.xz
    cd Python-$version
    CXX=gcc ./configure --prefix=$python_dst --enable-shared --enable-unicode=ucs4
    make
    make install
    $python_dst/bin/python -m ensurepip
    $python_dst/bin/pip install --upgrade pip
    # If we do not have a linked python install
    # Link this as the active/default install.
    if [[ ! -e $PYTHON_BIN ]]; then
      ln -s $python_dst $PYTHON_ACTIVE
      hash -r
    fi
    cd $original_dir
  fi
}

function install_ruby(){
  if [[ -z $1 ]]; then
    echo "Usage install_ruby [version number]";
  else
    original_dir=$CWD
    version=$1
    ruby_dst=$RUBY_BASE/$version
    echo "Installing Ruby ${version} from source."
    if [[ ! -d $LOCAL_SRC/ruby ]];then
      echo "Ruby source code not found locally, cloning from github."
      git clone https://github.com/ruby/ruby.git $LOCAL_SRC/ruby
    else
      cd $LOCAL_SRC/ruby
      git reset HEAD --hard
      git clean -f -d
      git fetch --all
    fi
    cd $LOCAL_SRC/ruby
    git checkout "v`echo $version | sed 's/\./_/g'`"
    autoconf
    ./configure --prefix=$ruby_dst
    make
    make install
    # If there is no active/default ruby install
    # lets link this one as the active.
    if [[ ! -e $RUBY_BIN ]]; then
      ln -s $ruby_dst $RUBY_ACTIVE
      hash -r
    fi
    cd $original_dir
  fi
}

# Install powerline patched fonts
function install_powerline_fonts(){
  if [[ ! -f ~/.config/dotfiles/powerline_fonts ]]; then
    echo "Installing patched powerline fonts"
    cd $LOCAL_SRC
    git clone https://github.com/powerline/fonts.git
    cd fonts
    ./install.sh && touch ~/.config/dotfiles/powerline_fonts
    cd $HOME
  fi
}


# Install Base-16 Shell themes
function install_base16(){
  if [ ! -d "$BASE_16_PATH" ]; then
    echo "Installing Base 16 Shell"
    git clone https://github.com/chriskempson/base16-shell.git $BASE_16_PATH
  fi
}

function install_misc_tools(){
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
}

# Install tmuxinator
function install_tmuxinator(){
  if [[ ! `command -v tmuxinator` ]]; then
    echo "Installing tmuxinator"
    gem install tmuxinator
    curl "https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh" > $LOCAL_BIN/tmuxinator.zsh
    hash -r
  fi
}

# Install oh-my-zsh
function install_oh_my_zsh(){
  if [[ ! -d $LOCAL_DIR/oh-my-zsh ]]; then
    echo "Installing oh-my-zsh"
    umask g-w,o-w
    git clone https://github.com/robbyrussell/oh-my-zsh.git $LOCAL_DIR/oh-my-zsh
  fi
}

# Install NeoBundle
function install_NeoBundle(){
  if [ ! -e ~/.vim/bundle/neobundle.vim/bin/neoinstall ]; then
    echo "Installing NeoBundle"
    curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh
  fi
}

# Install Go, this will insall 1.4.3 first.
function install_go(){
  if [[ -z $1 ]]; then
    echo "Usage install_go [version number]";
  else
    mkdir -p $GO_BASE
    original_version=$version
    version=$1
    original_dir=$CWD
    go_dst=$GO_BASE/$version
    if [[ ! -d $LOCAL_SRC/go ]]; then
      echo "Cloning go-lang git repo to ${LOCAL_SRC}/go"
      git clone https://github.com/golang/go.git $LOCAL_SRC/go
    fi
    # Ensure 1.4 is installed. 1.4 is 
    # required to build 1.5 and greater.
    if [[ $version != "1.4.3" ]]; then
      if [[ ! -d $GO_BASE/1.4.3 ]]; then
        echo "GO lang 1.5 and above requires 1.4 to build. Installing that first."
        install_go 1.4.3
        version=$original_version
        go_dst=$GO_BASE/$version
      fi
    fi
    # Checkout version and build
    cd $LOCAL_SRC/go
    echo "Cleaning go-lang git repo"
    git reset HEAD --hard
    git clean -xfd
    git checkout "go${version}"
    # Install files into $GO_BASE
    cp -r $LOCAL_SRC/go $go_dst
    # Remove git repo from destination
    rm -rf $go_dst/.git
    # Run the compile
    cd $go_dst/src
    if [[ $version != "1.4.3" ]]; then
      GOROOT_BOOTSTRAP=$GO_BASE/1.4.3 ./all.bash
    else
      ./all.bash
    fi
    if [[ -e $GO_ACTIVE ]]; then
      rm $GO_ACTIVE
    fi
    ln -s $go_dst $GO_ACTIVE
    hash -r
    cd $original_dir
  fi
}
