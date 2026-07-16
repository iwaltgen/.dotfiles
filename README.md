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

설치 과정에서 관리자 권한을 요청하거나 로그인 셸을 변경하고 외부 서비스에서 도구를 다운로드할 수 있습니다. 이 스크립트는 새 장비의 초기 설정을 위한 것으로, 다시 실행하면 이미 존재하는 복제 디렉터리나 파일 때문에 문제가 발생할 수 있습니다.

대부분의 독립형 명령줄 도구는 mise로 설치합니다. macOS 시스템 통합, 서비스 및 그래픽 애플리케이션은 계속해서 Homebrew로 관리합니다. mise의 `cargo:eza` 백엔드는 호환되는 사전 빌드 바이너리가 없을 때 eza를 소스에서 컴파일할 수 있습니다.

### GPG

선택 사항인 GPG 키 가져오기를 사용하려면 [Keybase](https://keybase.io/docs/the_app/install_macos)와 GnuPG가 필요합니다.

```sh
.gnupg/gpg-import-from-keybase.sh
```

이 스크립트는 현재 활성화된 Keybase 계정에서 키를 가져오고, 코드에 고정된 개인 키 ID에 대한 대화형 GPG 신뢰도 편집기를 엽니다. 다른 계정에서 사용하기 전에 스크립트를 검토하세요.

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
