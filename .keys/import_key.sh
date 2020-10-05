#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
KEYRING_HOME=$SCRIPTDIR/.gpg
REPO_SLUG=$1

function error {
  echo ${1:-"Unknown error"}
  exit 1
}

if [[ -z "$REPO_SLUG" ]]; then
  error "No repo specified"
fi

if [[ -z "$PASSPHRASE" ]]; then
  error "PASSPHASE must be set as environment"
fi

REPO_OWNER=$(echo $REPO_SLUG | sed 's/\([^\/]*\)\/.*/\1/g')

if [[ ! -e $SCRIPTDIR/$REPO_OWNER.key.gpg ]]; then
  error "No key for repo owner $REPO_OWNER exists"
fi

{ echo $PASSPHRASE | gpg --decrypt --passphrase-fd 0 --output $SCRIPTDIR/$REPO_OWNER.key $SCRIPTDIR/$REPO_OWNER.key.gpg ; } || error "Failed to decrypt key"

mkdir -p $KEYRING_HOME

{ gpg --home $KEYRING_HOME --import $SCRIPTDIR/$REPO_OWNER.key ; } || { error "Could not import key into gpg." ; }
