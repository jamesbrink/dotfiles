LOCAL_DIR := $(HOME)/local
LOCAL_BIN := $(LOCAL_DIR)/bin
LOCAL_LIB := $(LOCAL_DIR)/lib
LOCAL_OPT := $(LOCAL_DIR)/opt
LOCAL_SRC := $(LOCAL_DIR)/src
DOTFILES_BAK := $(HOME)/.dotfiles_bak

# Wonders why I used a Makefile lol
.PHONY: all install install_dotfiles clean cssh directories zshrc vimrc tmux tmuxinator gitconfig profile

all:
	@echo "install - Install dotfiles to $(HOME)"
	@echo "clean - remove $(LOCAL_DIR)"

install: directories install_dotfiles oh_my_zsh 

install_dotfiles: zshrc vimrc tmux tmuxinator gitconfig profile

clean:
	rm -rf $(LOCAL_DIR)

directories:
	mkdir -p $(LOCAL_DIR)
	mkdir -p $(LOCAL_SRC)
	mkdir -p $(LOCAL_BIN)

zshrc:
ifneq ("$(wildcard $(HOME)/.zshrc)","")
	mkdir -p $(DOTFILES_BAK)
	cp $(HOME)/.zshrc $(DOTFILES_BAK)
endif
	cp .zshrc $(HOME)

vimrc:
ifneq ("$(wildcard $(HOME)/.vimrc)","")
	mkdir -p $(DOTFILES_BAK)
	cp $(HOME)/.vimrc $(DOTFILES_BAK)
endif
	cp .vimrc $(HOME)

tmux:
ifneq ("$(wildcard $(HOME)/.tmux.conf)","")
	mkdir -p $(DOTFILES_BAK)
	cp $(HOME)/.tmux.conf $(DOTFILES_BAK)
endif
	cp .tmux_osx.conf $(HOME)
	cp .tmux_linux.conf $(HOME)

tmuxinator: 
ifneq ("$(wildcard $(HOME)/.tmuxinator)","")
	mkdir -p $(DOTFILES_BAK)
	cp -rv $(HOME)/.tmuxinator $(DOTFILES_BAK)
endif
	cp -rv .tmuxinator $(HOME)

gitconfig:
ifneq ("$(wildcard $(HOME)/.gitconfig)","")
	mkdir -p $(DOTFILES_BAK)
	cp $(HOME)/.gitconfig $(DOTFILES_BAK)
endif
	cp .gitconfig $(HOME)

profile: zshrc
ifneq ("$(wildcard $(HOME)/.profile)","")
	mkdir -p $(DOTFILES_BAK)
	cp $(HOME)/.profile $(DOTFILES_BAK)
endif
	cp .profile $(HOME)
	cp .functions.sh $(HOME)

oh_my_zsh:
	(umask g-w,o-w && git clone https://github.com/robbyrussell/oh-my-zsh.git $(LOCAL_DIR)/oh-my-zsh)
