# Project Name - HTTP-API-Client #

API Client

# SETUP #
--------------------------------------------------------------
## Setup your system with Docker and Vagrant ##

### Install Docker ###

p.s. If you already have docker, skip to next.

 >> sudo wget -q0- https://get.docker.com|sh
 >> sudo adduser $USER docker
 >> echo "export VAGRANT_DEFAULT_PROVIDER=docker" >> $HOME/.bashrc;
 >> export VAGRANT_DEFAULT_PROVIDER=docker
 >> sudo reboot
 
### Install Vagrant ###

p.s. If you already have vagrant, or use docker composer then skip to next.

Download the latest version from https://www.vagrantup.com/downloads.html

 >> sudo apt-get gdebi -y
 >> wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2_x86_64.deb -cO vagrant.deb
 >> sudo gdebi vagrant.deb --no

### Add ./bin and ./tools to PATH ###

p.s. If you have already done that, skip this one. do not over done.

 >> echo "export PATH=bin:tools:$PATH" >> ~/.bashrc

=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-===-=

## Runing and Testing ##

### Add dependancies and install locally ###

 >> echo 'requires "IO::File";' >> cpanfile
 >> carton install

### Run your code ###

 >> carton exec prove -lr t

### Get inside the container as normal user ###

 >> container inside

### Get inside the container as root ###

 >> container inside-root

## Finally, you coding structure is ready. Take care ##

ps. get a list of command of container commands

 >> container help

-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-===-=

## Coverage ##

 >> cpanm --installdeps --with-develop .
 >> PERL5LIB="lib:$PERL5LIB" PERL5OPT=-MDevel::Cover prove -r t
 >> PERL5LIB="lib:$PERL5LIB" cover

Threshold: **75% statement coverage** on `lib/`, tracked per-module. Current baseline (2026-08-17): `HTTP/API/Client.pm` 79.1% statement / 61.5% branch / 39.3% condition, `HTTP/API/DataTypeMarker.pm` 100%. Branch/condition coverage is measured and reported but not gated yet - most of the gap is the custom `engine` code path in `send()`, which isn't exercised by the current test suite (see HAC-004).

`cover_db/` is a generated artifact - never commit it.

-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-===-=

# Developers #

 * Michael Vu <email@michael.vu>

# License #

MIT
