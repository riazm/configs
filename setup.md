UBUNTU 17.10 setup

# Manually installed apps
android-tools-adb bison build-essential cabextract chromium-chromedriver cifs-utils curl default-jdk default-jre dkms docker-compose docker.io duplicity emacs expect flex git gnome-tweaks gnumeric google-chrome-stable gpaint gperf kolourpaint libicu-dev libssl-dev libwebpdemux2 libxslt1-dev mate-utils mtpaint net-tools nmap nodejs npm openssh-server orca qrencode r8168-dkms ruby screen smb4k smbclient sshpass unrar-free virtualbox w3m xclip


# python
pipenv is the best python environment thingie don't fight it
sudo apt install python3-jedi black python3-autopep8 yapf3 python3-yapfD



# zshrc
sudo apt-get install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo npm install --global pure-prompt
ln -s ~/Projects/configs/.zshrc
ln -s ~/Projects/configs/.zshrc.fluidicaliases

# Duel monitor support with displaylink:

https://support.displaylink.com/knowledgebase/articles/684649-how-to-install-displaylink-software-on-ubuntu

sudo apt-get install dkms

http://www.displaylink.com/downloads/ubuntu

# chrome

sudo apt install ./thechromedeb

# Dropbox

https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2015.10.28_amd64.deb
sudo apt-get install python-gpgme
sudo apt install ./dropbox_2015.10.28_amd64.deb

# shared drive

# email


# calendar

ditto email at the moment

# github
```sudo apt-get install git

ssh-keygen -t rsa -b 4096 -C "corporate-email-address"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

git config --global user.name "Riaz Moola"
git config --global user.email "corporate-email-address"
git config --global core.editor "nano"
PATH=$PATH:~/bin
source env-setup.sh
```
# emacs
```
sudo add-apt-repository ppa:kelleyk/emacs
sudo apt-get update
sudo apt-get install emacs

mkdir Projects && cd Projects
git clone https://github.com/riazm/configs.git
cd
ln -s ~/Projects/configs/.emacs
ln -s ~/Projects/configs/.emacs.d

install flycheck from package-list packages

```
## node.js js2 mode
```
cd ~/bin/
git clone git@github.com:ternjs/tern.git
cd tern
npm install
```
update .emacs with path to ~/bin
apt-get install node (but always use nvmversion)

## eslint
```
nvm deactivate
npm install -g eslint
eslint --init
```
or copy .eslint.rc.* into file

# slack

just get it 

# irc ?

whatever

# signal?

jq --compact-output if .envelope.isReceipt then {receiptFrom: .envelope.source} elif .envelope.dataMessage then {source: .envelope.source, message: .envelope.dataMessage.message} else empty end

https://github.com/AsamK/signal-cli/wiki/DBus-service
dbus running on system as signal-cli, pw in keep, register in signal-cli (the configs are linked to your local stuff for some reason)

to link try
 
qrencode -t ANSIUTF8 -o - "tsdevice:/?uuid=7xNI0jsecnqT8jMlXts0_w&pub_key=BYBA6phUvW1Bhwn1fnhY7aJ83cqf5PK%2FUGjh1202XQc0"

use signal-cli.bash fork on your own repo


# nvm 

https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-16-04

```
sudo apt-get install build-essential libssl-dev
curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh -o install_nvm.sh
bash install_nvm.sh
source ~/.profile
nvm install 8.9.4
nvm install 4.2.3
nvm use 8.9.4nvm install 8.9.4
```

# e2e tests
## JDK for selenium webdriver
q
```sudo apt-get install jdk```

## webdriver-manager
install using latest version of node so that you get the latest webdriver

    
