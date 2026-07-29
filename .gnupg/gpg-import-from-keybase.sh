#!/bin/zsh
#
# Keybase 서버에 보관된 PGP 키를 로컬 GnuPG 키링으로 가져옵니다.
#
# 암호 입력창은 세 번 뜨지만, 새로 기억할 암호는 하나뿐입니다.
#   1) Keybase 창 "protect your PGP key" : 지금 새로 정하는 값. 내보낼 키 블록을 감쌉니다.
#   2) Keybase 창 "reenter for confirmation" : 1) 의 확인 재입력.
#   3) pinentry 창 "to import the ... secret key" : 1) 에서 정한 값을 그대로 넣습니다.
#      GnuPG 가 블록을 열어 같은 암호로 private-keys-v1.d 에 저장하므로,
#      이후 커밋 서명 때 pinentry 가 묻는 값도 1) 과 같습니다.
#
# Keybase 계정 암호는 세션이 만료됐거나 `keybase passphrase remember` 가 꺼져 있을 때만
# 위 순서보다 먼저 추가로 물어봅니다.
#
# Docs: https://book.keybase.io/docs/crypto/pgp
# https://github.com/keybase/keybase-issues/issues/1264

set -euo pipefail

KEY_ID="${GPG_KEY_ID:-BD43BAEEFF6F625A}"

log() { print -r -- "==> $*"; }

if ! command -v keybase >/dev/null; then
  print -ru2 -- "keybase 가 없습니다: brew install --cask keybase"
  exit 1
fi

if ! keybase status 2>/dev/null | grep -q 'Logged in:[[:space:]]*yes'; then
  log "Keybase 로그인 (새 장비는 기존 장비 승인 또는 paper key 필요)"
  keybase login
fi

log "공개키 가져오기"
keybase pgp export --query "$KEY_ID" | gpg --import

log "비밀키 가져오기 (Keybase 창에서 새 암호를 정하고, pinentry 창에 같은 값을 입력)"
keybase pgp export --secret --query "$KEY_ID" | gpg --allow-secret-key-import --import

log "신뢰도 ultimate 설정"
fingerprint=$(gpg --with-colons --fingerprint "$KEY_ID" | awk -F: '/^fpr:/ { print $10; exit }')
print -r -- "${fingerprint}:6:" | gpg --import-ownertrust

log "가져온 키"
gpg --list-secret-keys --keyid-format=long "$KEY_ID"

log "확인 명령"
print -r -- "  echo test | gpg -e -r ${KEY_ID} | gpg -d"
print -r -- "  echo test | gpg --clearsign | gpg --verify"
print -r -- "  git commit --allow-empty -m 'test: gpg signing' && git log --show-signature -1 && git reset --hard HEAD~1"
