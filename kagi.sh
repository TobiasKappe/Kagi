#!/bin/bash

prompt () {
    zenity --title "$1 - Kagi" --text="$1" ${@:2}
}

prompt-text() {
    prompt "$1" --entry
}

prompt-error() {
    prompt "$1" --error
}

prompt-confirm() {
    zenity "$1" --question
}

get-key-path() {
    echo "$KAGI_BASEDIR/$1"
}

check-id() {
    [ "$1" == "${1//[^a-zA-Z0-9\-]/}" ]
}

check-exists() {
    [ -e "$(get-key-path "$1")" ]
}

check-overwrite() {
    if check-exists "$1"; then
        prompt-confirm "Key exists. Overwrite?"
    else
        true
    fi
}

get-key-id() {
    local KEY_ID=$(prompt-text "Key ID")

    if [ -z "$KEY_ID" ]; then
        prompt-error "No ID given."
        false
    elif ! check-id "$KEY_ID"; then
        prompt-error "Invalid ID."
        false
    else
        echo "$KEY_ID"
    fi
}

generate-key() {
    pwgen $KAGI_PWGEN_FLAGS -N 1
}

gpg-encrypt() {
    gpg -ea -r "$KAGI_GPG_KEY"
}

gpg-decrypt() {
    gpg -q -d
}

to-clipboard() {
    local OLDCONTENT=$(xclip -o $KAGI_XCLIP_FLAGS)
    xclip $KAGI_XCLIP_FLAGS
    (
        sleep $KAGI_SCRUB_TIMEOUT;
        echo -n "$OLDCONTENT" | xclip $KAGI_XCLIP_FLAGS
    ) &
}

if [ -z ${KAGI_GPG_KEY} ]; then
    prompt-error "No GPG key configured."
    exit 1
fi

# Careful: the first dash is bash syntax
KAGI_PWGEN_FLAGS="${KAGI_PWGEN_FLAGS:--nys 32}"
KAGI_XCLIP_FLAGS="${KAGI_XCLIP_FLAGS:--selection clipboard}"
KAGI_SCRUB_TIMEOUT="${KAGI_SCRUB_TIMEOUT:-5}"

XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
KAGI_BASEDIR="${XDG_DATA_HOME}/kagi"

if [ ! -d "$KAGI_BASEDIR" ]; then
    mkdir "$KAGI_BASEDIR"
fi

case "$1" in
write)
    KEY_ID=$(get-key-id) || exit 1

    if check-overwrite "$KEY_ID"; then
        KEY_PATH=$(get-key-path "$KEY_ID")
        generate-key | gpg-encrypt > "$KEY_PATH"
    fi
    ;;
read)
    KEY_ID=$(get-key-id) || exit 1

    if check-exists "$KEY_ID"; then
        KEY_PATH=$(get-key-path "$KEY_ID")
        gpg-decrypt < "$KEY_PATH" | to-clipboard
    else
        prompt-error "Unknown key"
    fi
    ;;
esac
