#!/bin/bash

KEYHOME=$(git rev-parse --show-toplevel)/.keys
export KEYRING_HOME=$KEYHOME/.gpg

echo "Fingerprint: $GPG_FINGERPRINT"

curl -sL https://git.io/goreleaser | bash -s - --rm-dist
