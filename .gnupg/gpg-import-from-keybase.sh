#!/bin/zsh

keybase login

# public key export
keybase pgp export | gpg --import

# private key export
# https://gist.github.com/simnalamburt/c921a9e70e9a43f5b4743499370d5a88
# https://github.com/keybase/keybase-issues/issues/1264
keybase pgp export --secret | gpg --allow-secret-key-import --import --batch

# trust key
gpg --edit-key BD43BAEEFF6F625A
# gpg> trust
# Your decision? 5
# Do you really want to set this key to ultimate trust? (y/N) y
# gpg> save

# test
# echo test | gpg -e -r iwaltgen@gmail.com | gpg -d
# echo test | gpg -e -r BD43BAEEFF6F625A | gpg -d --use-agent
