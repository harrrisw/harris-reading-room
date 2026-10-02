#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
export PATH="$ROOT/.bin:$PATH"
if ! command -v gum >/dev/null; then
    printf 'Gum is required for the UI. See README.md for installation.\n' >&2
    exit 1
fi
exec bash "$ROOT/ui/main_menu.sh"
