#!/bin/bash

KEYHOME=$(git rev-parse --show-toplevel)/.keys
export KEYRING_HOME=$KEYHOME/.gpg
export GPG_FINGERPRINT=$(gpg --home $KEYRING_HOME --list-keys | grep "^ " | cut -b 7-)

curl -sL https://git.io/goreleaser | bash