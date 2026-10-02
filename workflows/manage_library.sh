#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"
action=${1:-list}; shift || true
case "$action" in
    list) bash "$DB" list;;
    search) bash "$ROOT/books/search_books.sh" "$@";;
    add)
        [[ $# -ge 2 && $# -le 3 ]] || fail 'Usage: manage_library.sh add TITLE AUTHOR [STATUS]'
        metadata=$(bash "$ROOT/books/fetch_book_metadata.sh" "$1" "$2")
        IFS=$'\t' read -r title author genre year link <<< "$metadata"
        bash "$DB" add "$title" "$author" "$genre" "${3:-want-to-read}" 0 "$link" "$year";;
    status|rating) bash "$DB" "$action" "$@";;
    *) fail 'Unknown library action.';;
esac
