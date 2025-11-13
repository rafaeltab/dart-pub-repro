# Dart/Flutter pub issue

This is a repro for a `dart pub`/`flutter pub` issue related to git and tags.

## Reproduce

Use the `reproduce.sh` script to reproduce the issue.

This repository assumes you have `fvm` installed for managing flutter versions, and that it's in your `PATH`.
If you don't have `fvm` and don't want it, you can install version `3.35.6` and replace any `fvm flutter` with `flutter` commands.

This repository also assumes that it's okay to remove everything in your `~/.pub-cache` directory, using `fvm flutter pub cache clean -f`.
If it's not, make sure to comment that line in the `./reproduce.sh` script. I can not guarantee that reproducing will be reliable without it.

I ran this on mac, if you're on a different OS, I think it should work as long as sh is available.
