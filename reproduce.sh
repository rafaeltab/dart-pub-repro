#!/bin/sh

if ! command -v fvm &> /dev/null 
then
    echo "\033[0;31mThis repro assumes you have fvm installed. This script uses it to switch to the correct flutter version for reproduction\033[0m"
    exit 1
fi

fvm install
fvm use

# Make sure the cache does not interfere in our repro
fvm flutter pub cache clean -f

cd apps/reproducing_app
# Make sure the pubspec.lock does not interfere in our repro
rm -f pubspec.lock
fvm flutter pub get
cd ..
