#!/usr/bin/env bash

rm -d /etc/nixos
ln -s $PWD /etc/nixos

nix-channel --add https://github.com/musnix/musnix/archive/master.tar.gz musnix
nix-channel --update musnix
