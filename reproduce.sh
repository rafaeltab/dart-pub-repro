#!/bin/sh

if ! command -v fvm &> /dev/null 
then
    echo "\033[0;31mThis repro assumes you have fvm installed. This script uses it to switch to the correct flutter version for reproduction\033[0m"
    exit 1
fi


