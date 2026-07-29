#!/bin/zsh
#
# Keybase 에 보관된 PGP 키를 로컬 GnuPG 키링으로 가져온다.
#
# 암호 입력창은 세 번 뜨지만 새로 기억할 암호는 하나뿐이다. Keybase 가 내보낼
# 키 블록을 감쌀 새 암호를 묻고, 확인을 위해 한 번 더 묻고, 이어서 pinentry 가
# 같은 값을 다시 묻는다. GnuPG 는 그 암호로 블록을 열어 동일한 암호로
# private-keys-v1.d 에 저장하므로 이후 커밋 서명 때도 같은 값을 쓴다.
# Keybase 계정 암호는 세션이 만료됐을 때만 그보다 먼저 추가로 묻는다.
#
# Docs: https://book.keybase.io/docs/crypto/pgp
# https://gist.github.com/simnalamburt/c921a9e70e9a43f5b4743499370d5a88
# https://github.com/keybase/keybase-issues/issues/1264

set -euo pipefail

key_id="${GPG_KEY_ID:-BD43BAEEFF6F625A}"

fail() {
  print -u2 -- "gpg-import-from-keybase: $1"
  exit 1
}

report() {
  print -- "gpg-import-from-keybase: $1"
}

[[ -n "${commands[keybase]:-}" ]] || fail "keybase 를 찾을 수 없습니다. brew install --cask keybase"
[[ -n "${commands[gpg]:-}" ]] || fail "gpg 를 찾을 수 없습니다"

if ! keybase status 2>/dev/null | grep -q 'Logged in:[[:space:]]*yes'; then
  report "Keybase 에 로그인합니다. 새 장비는 기존 장비의 승인이나 paper key 가 필요합니다"
  keybase login
fi

report "공개키를 가져옵니다"
keybase pgp export --query "$key_id" | gpg --import

report "비밀키를 가져옵니다"
keybase pgp export --secret --query "$key_id" | gpg --allow-secret-key-import --import

report "신뢰도를 ultimate 로 설정합니다"
fingerprint="$(gpg --with-colons --fingerprint "$key_id" | awk -F: '/^fpr:/ { print $10; exit }')"
[[ -n "$fingerprint" ]] || fail "$key_id 의 fingerprint 를 찾지 못했습니다"
print -r -- "${fingerprint}:6:" | gpg --import-ownertrust

gpg --list-secret-keys --keyid-format=long "$key_id"

# 확인
# echo test | gpg --clearsign | gpg --verify
# echo test | gpg -e -r iwaltgen@gmail.com | gpg -d
