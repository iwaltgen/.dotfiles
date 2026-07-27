# 프로젝트 개요

- Apple Silicon 기반 macOS와 Ubuntu Linux에서 사용하는 개인 dotfiles 저장소입니다.
- 설치 진입점은 `bin/setup.sh`이며, 저장소가 `$HOME/.dotfiles`에 있다고 가정합니다.

## 변경 원칙

- 공통 설정과 운영체제별 설정(`*.darwin`, `*.linux`)의 경계를 유지합니다.
- 링크 대상, 부트스트랩 동작, 도구 목록을 변경하면 `tests/setup_idempotency_test.zsh`의 픽스처와 단언도 함께 갱신합니다.
- `main` 브랜치에서 바로 작업할 수 있습니다. 커밋·푸시는 별도의 사용자 요청이 있을 때만 수행합니다.

## 도구 관리

- CLI 도구는 mise로 관리하고, mise 레지스트리에 백엔드가 없는 것만 brew에 남깁니다.
- 백엔드는 `aqua`·`core`(체크섬·증명 검증) > `conda`(sha256) > `npm`·`pipx`(버전만) 순으로 고르고, 하위를 쓰면 이유를 커밋에 남깁니다.
- 플랫폼별로 백엔드가 갈리면 `os = [...]`로 분기합니다(`fd`, `eza`, `pnpm` 참고).
- `mise/config.toml`에 `[settings]` 블록을 두지 않습니다. `minimum_release_age`(기본 24h)는 공급망 방어이므로 끄지 않고, 완화는 `[tools]`에서 도구별로 합니다.
- `mise.lock`은 쓰지 않습니다. 현재 플랫폼 항목만 기록되어 머신 간 diff가 오갑니다.
- 백엔드를 옮기면 `mise uninstall --all <이전키>`로 이전 설치본도 지웁니다. `mise prune`은 설정의 키만 보므로 고아가 남습니다.

## 검증

- 설정 스크립트 변경 후 `zsh tests/setup_idempotency_test.zsh`를 실행합니다.
