#!/usr/bin/env bash
set -euo pipefail

: "${MOCK_GH_DIR:?}"
if [[ "$1 $2" == 'pr list' ]]; then
  if [[ -f "$MOCK_GH_DIR/pr" ]]; then
    cat "$MOCK_GH_DIR/pr"
  fi
elif [[ "$1 $2" == 'pr create' ]]; then
  printf '%s\n' attempt >> "$MOCK_GH_DIR/attempts"
  if [[ "${MOCK_FAIL_CREATE:-false}" == true ]]; then
    exit 1
  fi
  while [[ $# -gt 0 ]]; do
    if [[ "$1" == --body-file ]]; then
      cp "$2" "$MOCK_GH_DIR/body"
      break
    fi
    shift
  done
  printf 'OPEN\thttps://example.invalid/training/sample/pull/1\n' > "$MOCK_GH_DIR/pr"
  printf '%s\n' 'https://example.invalid/training/sample/pull/1'
else
  printf '%s\n' 'Unexpected mock gh call' >&2
  exit 1
fi