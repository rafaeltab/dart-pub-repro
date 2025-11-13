# Dart/Flutter pub issue

This is a repro for a `dart pub`/`flutter pub` issue related to git and tags.
Use the `reproduce.sh` script to reproduce the issue.
This repository assumes you have `fvm` installed for managing flutter versions, and that it's in your `PATH`.
This repository also assumes that it's okay to remove everything in your `~/.pub-cache` directory, using `fvm flutter pub cache clean -f`.
