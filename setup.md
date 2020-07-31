UBUNTU 17.10 setup

# Manually installed apps
android-tools-adb
bison
build-essential
cabextract
chromium-chromedriver
cifs-utils
curl
default-jdk
default-jre
dkms
docker-compose
docker.io
dropbox
duplicity
emacs
emacs25
expect
flex
git
gnome-tweaks
gnumeric
google-chrome-stable
google-play-music-desktop-player
gpaint
gperf
kolourpaint
libgconf2-4
libicu-dev
libqpdf21
libssl-dev
libwebpdemux2
libxslt1-dev
mate-utils
mongodb-clients
mosquitto
mosquitto-clients
mtpaint
ndiswrapper
net-tools
nmap
nodejs
nomachine
npm
openprinting-ppds-postscript-ricoh
openssh-server
orca
python
python3-pip
python3-smbc
python-gi
python-pip
qrencode
r8168-dkms
ruby
screen
scudcloud
signal-desktop
smb4k
smbclient
sshpass
unrar-free
veeam
veeam-release-deb
virtualbox
w3m
winehq-devel
wine-stable
xclip


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

https://mail.elektronuser.com/owa/ for now

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
cd 
git init .
git remote add -t \* -f origin https://github.com/riazm/configs.git
git checkout master
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
dbus running on system as signal-cli, pw scrambled, use signal-cli.bash fork on your own repo

to link try
 
`qrencode -t ANSIUTF8 -o - "tsdevice:/?uuid=QGeXLf0s1HyJJtxwqhV2yg&pub_key=BbG5m907zWH3L9IHlHH5N6qomt%2BLQEGvri%2F5wcu5uGZm"'


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

    
