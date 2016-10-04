#!/bin/bash

for i in dotfiles/*; do
    dest=$HOME/.$(basename $i)
    full=$PWD/$i
    if [ -e $dest ]
    then
        echo "skipping $dest <- $full"
    else 
        echo "linking $dest <- $full"
        ln -s $full $dest
    fi
done
