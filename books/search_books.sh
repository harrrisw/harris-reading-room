#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"
[[ $# -le 1 ]] || fail 'Usage: search_books.sh [TERM] (or pipe a term on stdin)'
if [[ $# == 1 ]]; then term=$1; else IFS= read -r term || [[ -n "${term:-}" ]] || fail 'Provide a search term.'; fi
exec bash "$DB" search "$term"
