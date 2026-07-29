#!/bin/zsh

set -eu

[[ "$(uname -s)" == Darwin ]] || exit 0

# 사용법: ensure-superpowers-docs-link.darwin.sh [프로젝트 이름] [프로젝트 경로]
project_path="${2:-$PWD}"
project_path="${project_path:a}"
project_name="${1:-}"

if [[ -z "$project_name" ]]; then
  project_name="${project_path:t}"
  # 숨김 디렉토리 저장소는 문서 디렉토리 이름에서 앞의 점을 뗍니다.
  project_name="${project_name#.}"
fi

readonly superpowers_root="$HOME/syncthing/agents/superpowers"
readonly docs_target="$superpowers_root/$project_name"
readonly docs_link="$project_path/docs/superpowers"

if [[ ! -d "$project_path" ]]; then
  print -u2 -- "프로젝트 경로가 존재하지 않습니다: $project_path"
  exit 1
fi

if [[ -L "$docs_link" ]]; then
  if [[ "$(readlink "$docs_link")" == "$docs_target" ]]; then
    exit 0
  fi

  print -u2 -- "Superpowers 문서 링크가 다른 곳을 가리킵니다: $docs_link"
  exit 1
fi

if [[ -e "$docs_link" ]]; then
  print -u2 -- "Superpowers 문서 경로가 링크가 아닌 파일로 존재합니다: $docs_link"
  exit 1
fi

if [[ ! -d "$superpowers_root" ]]; then
  print -u2 -- "Syncthing 대상이 준비되지 않아 문서 링크를 건너뜁니다: $superpowers_root"
  exit 0
fi

mkdir -p "$docs_target"
mkdir -p "${docs_link:h}"
ln -s "$docs_target" "$docs_link"
