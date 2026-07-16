# 프로젝트 개요

- Apple Silicon 기반 macOS와 Ubuntu Linux에서 사용하는 개인 dotfiles 저장소입니다.
- 설치 진입점은 `bin/setup.sh`이며, 저장소가 `$HOME/.dotfiles`에 있다고 가정합니다.

## 변경 원칙

- 공통 설정과 운영체제별 설정(`*.darwin`, `*.linux`)의 경계를 유지합니다.
- 링크 대상이나 부트스트랩 동작을 변경하면 `tests/setup_idempotency_test.zsh`의 픽스처와 단언도 함께 갱신합니다.
- `main` 브랜치에서 바로 작업할 수 있습니다. 커밋·푸시는 별도의 사용자 요청이 있을 때만 수행합니다.

## 검증

- 설정 스크립트 변경 후 `zsh tests/setup_idempotency_test.zsh`를 실행합니다.
