#!/bin/bash

set -e
set -x

function error {
  echo ${1:-"Unknown error"}
  exit 1
}

gpg --version

KEYHOME=$(git rev-parse --show-toplevel)/.keys
KEYRING_HOME=$KEYHOME/.gpg
REPO_SLUG=$1

if [[ -z "$REPO_SLUG" ]]; then
  error "No repo specified"
fi

if [[ -z "$PASSPHRASE" ]]; then
  error "PASSPHASE must be set as environment"
fi

PASSPHRASE=$(echo -n $PASSPHRASE | base64 -d)

REPO_OWNER=$(echo $REPO_SLUG | sed 's/\([^\/]*\)\/.*/\1/g')

if [[ ! -e $KEYHOME/$REPO_OWNER.key.gpg ]]; then
  error "No key for repo owner $REPO_OWNER exists"
fi

rm -rf $KEYRING_HOME
rm -f $KEYHOME/$REPO_OWNER.key

mkdir -p $KEYRING_HOME
chmod 0700 $KEYRING_HOME

# Import Public Keys
for f in $KEYHOME/public/*; do
  { gpg --home $KEYRING_HOME --import $f ; } || { error "Could not import public key into gpg." ; }
done

{ echo -n $PASSPHRASE | gpg --home $KEYRING_HOME --decrypt --batch --passphrase-fd 0 --output $KEYHOME/$REPO_OWNER.key $KEYHOME/$REPO_OWNER.key.gpg ; } || error "Failed to decrypt key"

{ gpg --home $KEYRING_HOME --import $KEYHOME/$REPO_OWNER.key ; } || { error "Could not import key into gpg." ; }
