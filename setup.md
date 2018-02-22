UBUNTU 17.10 setup

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
sudo apt-get install git

ssh-keygen -t rsa -b 4096 -C "corporate-email-address"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

git config --global user.name "Riaz Moola"
git config --global user.email "corporate-email-address"
git config --global core.editor "nano"
PATH=$PATH:~/bin
source env-setup.sh

# emacs

sudo add-apt-repository ppa:kelleyk/emacs
sudo apt-get update
sudo apt-get install emacs
cd 
git init .
git remote add -t \* -f origin https://github.com/riazm/configs.git
git checkout master

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




