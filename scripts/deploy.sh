#!/bin/bash

KEYHOME=$(git rev-parse --show-toplevel)/.keys
export KEYRING_HOME=$KEYHOME/.gpg
export GPG_FINGERPRINT=$(gpg --home $KEYRING_HOME --list-keys | grep "^ " | cut -b 7-)

gpg --home $KEYRING_HOME --list-keys

echo "Fingerprint: $GPG_FINGERPRINT"

curl -sL https://git.io/goreleaser | bash
