# macOS Apple Silicon 및 Ubuntu용 Dotfiles

Apple Silicon 기반 macOS 및 Ubuntu Linux용 개인 설정과 부트스트랩 스크립트입니다.

## 지원 시스템

- Apple Silicon 기반 macOS
- Ubuntu Linux

macOS 부트스트랩은 Homebrew가 `/opt/homebrew`에 설치되어 있다고 가정합니다. Linux 부트스트랩은 Ubuntu 전용 `apt` 저장소와 패키지를 사용합니다.

## 시작하기 전에

스크립트는 이 저장소가 `$HOME/.dotfiles`에 체크아웃되어 있다고 가정합니다. 다른 위치에 복제하면 설정 및 심볼릭 링크 단계에서 사용하는 고정 경로가 올바르게 작동하지 않습니다.

- 설정 진입점을 실행하기 전에 [Zsh](https://zsh.sourceforge.io/)를 설치하세요.
- 이 저장소를 복제하기 전에 [Git](https://git-scm.com/)을 설치하세요.
- Ubuntu에서는 필요한 경우 `sudo apt install zsh git`으로 두 필수 도구를 모두 설치하세요.

Homebrew와 mise는 설정 스크립트가 설치하므로 사전 준비 항목이 아닙니다.

## 설치

```sh
git clone git@github.com:iwaltgen/.dotfiles.git "$HOME/.dotfiles"
cd "$HOME/.dotfiles"
./bin/setup.sh
```

설치 과정에서 관리자 권한을 요청하거나 로그인 셸을 변경하고 외부 서비스에서 도구를 다운로드할 수 있습니다. 이 스크립트는 새 장비의 초기 설정을 위한 것이지만 반복 실행할 수 있습니다. 이미 설치된 부트스트랩 구성 요소는 건너뛰고 패키지 선언과 심볼릭 링크는 다시 적용합니다. 링크 목적지에 일반 파일이나 실제 디렉터리가 있으면 날짜가 붙은 백업으로 옮긴 뒤 저장소 설정을 연결합니다. 설치가 끝나면 새 터미널을 열어 변경된 셸 설정을 적용하세요.

대부분의 독립형 명령줄 도구는 mise로 설치합니다. 추적되는 전역 도구 선언은 [`mise/config.toml`](mise/config.toml)에 있으며, setup이 이를 `~/.config/mise/config.toml`에 연결한 뒤 `$HOME`을 기준으로 `mise install --yes`를 한 번 실행합니다. 장비별·실험적 도구는 저장소에서 추적하지 않는 `~/mise.local.toml`에 선언할 수 있습니다. setup은 호출한 프로젝트의 mise 설정이 섞이지 않도록 설정 탐색 범위를 `$HOME`으로 제한합니다. 도구 버전은 `latest`, `lts` 또는 메이저 버전 범위로 선언해 실행 시점의 최신 호환 버전을 사용하며 `mise.lock`은 만들지 않습니다.

Homebrew는 macOS 부트스트랩, 서비스, 시스템 통합, 네이티브 라이브러리와 그래픽 애플리케이션을 담당합니다. setup은 Brewfile에서 빠진 기존 formula를 자동으로 제거하지 않습니다. mise 이전이 확인된 뒤 기존 Homebrew 설치를 정리하는 방법은 [`brew/README.md`](brew/README.md)를 참고하세요.

### GPG

선택 사항인 GPG 키 가져오기를 사용하려면 [Keybase](https://keybase.io/docs/the_app/install_macos)와 GnuPG가 필요합니다.

```sh
.gnupg/gpg-import-from-keybase.sh
```

이 스크립트는 Keybase 로그인 여부를 확인한 뒤 공개키와 비밀키를 가져오고, 대상 키의 신뢰도를 ultimate로 설정합니다. 키 ID는 `GPG_KEY_ID` 환경 변수로 덮어쓸 수 있으며 기본값은 코드에 고정되어 있습니다. 다른 계정에서 사용하기 전에 스크립트를 검토하세요.

가져오는 동안 암호 입력창이 세 번 뜨지만 새로 기억할 암호는 하나뿐입니다. Keybase 창이 내보낼 키 블록을 감쌀 새 암호를 묻고(확인까지 두 번), 이어서 pinentry 창이 `to import`라는 문구로 같은 값을 다시 묻습니다. GnuPG가 그 암호로 블록을 열어 동일한 암호로 `private-keys-v1.d`에 저장하므로, 이후 커밋 서명 때 pinentry가 묻는 값도 같습니다. Keybase 계정 암호는 세션이 만료됐거나 `keybase passphrase remember`가 꺼져 있을 때만 그보다 먼저 추가로 물어봅니다.

Keybase 경로는 계정 로그인과 앱 상태에 의존합니다. 새 장비에서 `keybase login`은 기존 장비의 승인이나 paper key를 요구하며, 앱이 오래되면 서버 인증서 검증에 실패해 `keybase pgp export --secret`이 동작하지 않습니다. 그래서 이 경로에만 의존하지 말고 아래 오프라인 백업을 함께 유지합니다.

#### 키 백업

`~/.gnupg`를 대칭키로 암호화해 별도 보관합니다. tar 출력을 파이프로 넘겨 평문이 디스크에 남지 않게 합니다. 락 파일은 이름에 호스트명과 PID가 박혀 있어 다른 장비에서 복원하면 keyboxd가 남의 락으로 오인해 멈출 수 있으므로 아카이브에서 제외합니다.

```sh
tar -C "$HOME" --exclude='.gnupg/S.*' --exclude='*.lock' --exclude='*.#lk*' -czf - .gnupg \
  | gpg --symmetric --cipher-algo AES256 --s2k-digest-algo SHA512 \
        -o "$HOME/SECRET_KEY_PATH/gnupg-$(date +%Y%m%d).tar.gz.gpg"
```

`~/.ssh`도 같은 방식으로 보관할 수 있습니다. GPG 복구에는 필요 없는 선택 사항이지만, SSH 키는 Keybase가 담지 않으므로 이 백업이 유일한 경로입니다.

```sh
tar -C "$HOME" --exclude='.ssh/agent' -czf - .ssh \
  | gpg --symmetric --cipher-algo AES256 --s2k-digest-algo SHA512 \
        -o "$HOME/SECRET_KEY_PATH/ssh-$(date +%Y%m%d).tar.gz.gpg"
```

#### 키 복원

`tar -x`는 아카이브에 있는 파일만 덮어쓰고 기존 파일은 그대로 남깁니다. GnuPG 2.5는 keyboxd(`public-keys.d/`)를 쓰는 반면 예전 아카이브에는 `pubring.kbx`가 들어 있어, 정리 없이 풀면 두 저장소가 한 디렉터리에 섞입니다. 복원 전에 기존 키 저장소를 비웁니다.

```sh
gpgconf --kill all
rm -rf "$HOME"/.gnupg/private-keys-v1.d "$HOME"/.gnupg/public-keys.d
rm -f  "$HOME"/.gnupg/pubring.kbx "$HOME"/.gnupg/pubring.kbx~ \
       "$HOME"/.gnupg/trustdb.gpg "$HOME"/.gnupg/tofu.db "$HOME"/.gnupg/random_seed

gpg -d "$HOME/SECRET_KEY_PATH/gnupg-<날짜>.tar.gz.gpg" | tar -C "$HOME" -xzf -

chmod 700 "$HOME/.gnupg"
find "$HOME/.gnupg" \( -name '.#lk*' -o -name '*.lock' \) -delete
gpg --list-secret-keys
```

락 파일은 백업할 때 제외하지만 예전 아카이브에는 남아 있을 수 있어, 복원 후 하위 디렉터리까지 훑어 지웁니다. `~/.ssh`를 함께 보관했다면 아래를 이어서 실행합니다.

```sh
gpg -d "$HOME/SECRET_KEY_PATH/ssh-<날짜>.tar.gz.gpg" | tar -C "$HOME" -xzf -
```

아카이브를 만들면 옮기기 전에 `gpg -d <파일> | tar tzf -`로 목록을 확인해 복원 가능 여부를 검증합니다.

### Zinit

모든 Zinit 플러그인을 다시 설치합니다.

```sh
zinit delete --all --yes && exec zsh
```

### Atuin

로그인한 후 셸 기록을 동기화합니다.

```sh
# atuin register -u iwaltgen -e iwaltgen@gmail.com

atuin login -u iwaltgen
atuin sync
```

## 참고 자료

- [mise](https://mise.jdx.dev/): 개발 환경 및 도구 버전 관리자
- [Homebrew](https://brew.sh/): macOS용 패키지 관리자
- [Zinit](https://github.com/zdharma-continuum/zinit): Zsh 플러그인 관리자
- [Neovim](https://neovim.io/): 확장 가능한 Vim 기반 텍스트 편집기
- [AstroNvim](https://github.com/AstroNvim/AstroNvim): Neovim 설정 프레임워크
