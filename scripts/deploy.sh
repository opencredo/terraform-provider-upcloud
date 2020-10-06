#!/bin/bash

echo "Fingerprint: $GPG_FINGERPRINT"

curl -sL https://git.io/goreleaser | bash
