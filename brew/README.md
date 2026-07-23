# Homebrew

## bundle dump

```sh
rm -f Brewfile && brew bundle dump
```

## bundle

```sh
brew bundle
```

## mise 마이그레이션 정리

먼저 저장소 루트에서 `./bin/setup.sh`를 실행하고 새 터미널을 연 뒤, mise로 이전된 CLI가 정상 실행되는지 확인합니다.
그 다음 macOS에서만 다음 스크립트를 명시적으로 실행합니다.

```sh
./bin/cleanup-homebrew.darwin.sh
```

이 스크립트는 승인된 이전·제거 대상 formula와 Codex·Claude Code 계열 cask를 실제로 제거합니다.
Brewfile formula, 무관한 기존 leaf, 다른 설치 항목이 사용하는 공유 의존성은 보존합니다.
마지막 `brew autoremove` 단계만 `--dry-run` 미리보기이며, 전체 autoremove는 자동 실행하지 않습니다.
