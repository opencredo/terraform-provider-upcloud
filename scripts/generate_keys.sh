#!/bin/bash

TEMP_DIR=$(mktemp -d --tmpdir generate_keys.XXXXX)
KEYHOME=$(git rev-parse --show-toplevel)/.keys

KEY_NAME=$1
if [[ -z "$KEY_NAME" ]]; then
  echo "Please specifiy a name for this key"
  exit 1
fi

gpg --home $TEMP_DIR --full-gen-key --expert

KEY=$(gpg --home $TEMP_DIR --list-keys | grep '^ ' | cut -b 31-)

gpg --home $TEMP_DIR --edit-key --expert $KEY

gpg --home $TEMP_DIR --export-secret-key --armor -o $TEMP_DIR/$KEY.priv.asc $KEY
gpg --home $TEMP_DIR --export-secret-subkeys --armor -o $TEMP_DIR/$KEY.sub_priv.asc $KEY
gpg --home $TEMP_DIR --export --armor -o $TEMP_DIR/$KEY_NAME.pub.key $KEY

dd if=/dev/urandom count=1024 | sha256sum | cut -b -64 > $KEY_NAME.pwd

cat $KEY_NAME.pwd | gpg --home $TEMP_DIR --batch --passphrase-fd 0 --symmetric --cipher-algo AES256 --output $TEMP_DIR/$KEY_NAME.priv.key.gpg $TEMP_DIR/$KEY.sub_priv.asc
cp $TEMP_DIR/$KEY_NAME.pub.key $KEYHOME
cp $TEMP_DIR/$KEY_NAME.priv.key.gpg $KEYHOME

#rm -rf $TEMP_DIR