# Kagi - Stupidly simple password manager

Kagi is a password manager written in Bash. Its features include (and are limited to):

* Generating random passwords using [pwgen](https://sourceforge.net/projects/pwgen/)
* Storing encrypted passwords on-disk using [GnuPG](https://www.gnupg.org/)
* Decrypting passwords into your X clipboard using [xclip](https://github.com/astrand/xclip)
* Barebones GUI interface using [Zenity](https://help.gnome.org/users/zenity/stable/)

## Dependencies
In addition to Bash, the tools mentioned above must be installed on your system for Kagi to work properly.

## Configuration
First, make sure you have GPG key available (you may want to use a subkey of your current key). Then, tell Kagi which key you want to use by putting the following in your `.bashrc`:

    export KAGI_GPG_KEY="your@key.id"

## Usage
To generate a new password, invoke `./kagi.sh write` and provide a short alphanumeric ID for the key.

To read a stored password, run `./kagi.sh read` and provide the short key ID.

## Storage
Encrypted passwords are stored in `$XDG_DATA_DIR/kagi`. If this variable is not set, storage defaults to `$HOME/.local/share/kagi`.
