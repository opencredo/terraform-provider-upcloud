#!/bin/bash

function error {
  echo ${1:-"Unknown error"}
  exit 1
}

KEYHOME=$(git rev-parse --show-toplevel)/.keys
KEYRING_HOME=$KEYHOME/.gpg
REPO_SLUG=$1

if [[ -z "$REPO_SLUG" ]]; then
  error "No repo specified"
fi

if [[ -z "$PASSPHRASE" ]]; then
  error "PASSPHASE must be set as environment"
fi

REPO_OWNER=$(echo $REPO_SLUG | sed 's/\([^\/]*\)\/.*/\1/g')

if [[ ! -e $KEYHOME/$REPO_OWNER.key.gpg ]]; then
  error "No key for repo owner $REPO_OWNER exists"
fi

{ echo -n $PASSPHRASE | gpg --decrypt --batch --passphrase-fd 0 --output $KEYHOME/$REPO_OWNER.key $KEYHOME/$REPO_OWNER.key.gpg ; } || error "Failed to decrypt key"

mkdir -p $KEYRING_HOME

{ gpg --home $KEYRING_HOME --import $KEYHOME/$REPO_OWNER.key ; } || { error "Could not import key into gpg." ; }
