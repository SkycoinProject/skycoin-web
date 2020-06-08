#!/usr/bin/env bash

set -e -o pipefail

KEY_CHAIN=build.keychain
echo "security create keychain"
if ! security show-keychain-info "$KEY_CHAIN" ; then
  security -v create-keychain -p "$OSX_KEYCHAIN_PWD" "$KEY_CHAIN"
fi
# Make the keychain the default so identities are found
echo "security default-keychain"
security -v default-keychain -s "$KEY_CHAIN"
# Unlock the keychain
echo "unlock the keychain"
security -v unlock-keychain -p "$OSX_KEYCHAIN_PWD" "$KEY_CHAIN"
# Set keychain locking timeout to 3600 seconds
echo "set keychain locking timeout to 3600"
security -v set-keychain-settings -t 3600 -u "$KEY_CHAIN"

# Add certificates to keychain and allow codesign to access them
echo "import distp12"
security -v import $GOPATH/src/github.com/skycoinproject/skycoin-web/ci-scripts/certs/dist.p12 -k "$KEY_CHAIN" -P "$CERT_PWD"  -A /usr/bin/codesign

echo "list keychains: "
security list-keychains
echo " ****** "

echo "find indentities keychains: "
security find-identity -p codesigning  ~/Library/Keychains/$KEY_CHAIN
echo " ****** "
