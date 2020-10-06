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

REPO_OWNER=$(echo $REPO_SLUG | sed 's/\([^\/]*\)\/.*/\1/g')

if [[ ! -e $KEYHOME/$REPO_OWNER.priv.key.gpg ]]; then
  error "No key for repo owner $REPO_OWNER exists"
fi

rm -rf $KEYRING_HOME
rm -f $KEYHOME/$REPO_OWNER.key

mkdir -p $KEYRING_HOME
chmod 0700 $KEYRING_HOME

{ echo -n $PASSPHRASE | gpg --home $KEYRING_HOME --decrypt --batch --passphrase-fd 0 --output $KEYHOME/$REPO_OWNER.priv.key $KEYHOME/$REPO_OWNER.priv.key.gpg ; } || { error "Unable to decrypt key" ; }

{ gpg --home $KEYRING_HOME --import $KEYHOME/$REPO_OWNER.pub.key ; } || { error "Could not import public key into gpg." ; }
{ gpg --home $KEYRING_HOME --import $KEYHOME/$REPO_OWNER.priv.key ; } || { error "Could not import key into gpg." ; }
