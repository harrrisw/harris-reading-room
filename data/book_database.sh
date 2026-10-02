#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"
store=${BOOK_DB:-$ROOT/data/books.csv}
export DB_OP=${1:-list} DB_TITLE=${2:-} DB_AUTHOR=${3:-} DB_QUERY=${2:-} DB_VALUE=${4:-}
status_ok() { case "$1" in owned|want-to-read|reading|finished) ;; *) fail 'Status must be owned, want-to-read, reading, or finished.';; esac; }
rating_ok() { [[ "$1" =~ ^[0-5]$ ]] || fail 'Rating must be 0 (unrated) through 5.'; }
case "$DB_OP" in
    list) [[ $# -le 1 ]] || fail 'Usage: book_database.sh list';;
    search) [[ $# == 2 ]] || fail 'Usage: book_database.sh search TERM';;
    exists) [[ $# == 3 ]] || fail 'Usage: book_database.sh exists TITLE AUTHOR';;
    add)
        [[ $# == 8 ]] || fail 'Usage: book_database.sh add TITLE AUTHOR GENRE STATUS RATING LINK YEAR'
        required "$2" Title; required "$3" Author
        for field in "${@:2}"; do clean_field "$field"; done
        status_ok "$5"; rating_ok "$6"
        [[ "$8" == unknown || "$8" =~ ^[0-9]{4}$ ]] || fail 'Year must be four digits or unknown.';;
    status|rating)
        [[ $# == 4 ]] || fail 'Usage: book_database.sh status|rating TITLE AUTHOR VALUE'
        if [[ "$DB_OP" == status ]]; then status_ok "$4"; else rating_ok "$4"; fi;;
    *) fail 'Unknown database operation.';;
esac
mkdir -p -- "$(dirname -- "$store")"
# All writers (including initialization) share a lock; readers see atomic snapshots.
locked=0; temp=''
cleanup() { [[ -z "$temp" ]] || rm -f -- "$temp"; if ((locked)); then rmdir -- "$store.lock"; fi; }
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
lock() {
    local i
    for ((i=0;i<100;i++)); do
        if mkdir -- "$store.lock" 2>/dev/null; then locked=1; return; fi
        sleep 0.05
    done
    fail "Database is busy: $store.lock"
}
if [[ ! -f "$store" || "$DB_OP" == add || "$DB_OP" == status || "$DB_OP" == rating ]]; then
    lock
    if [[ ! -f "$store" ]]; then printf 'title,author,genre,status,rating,link,year\n' > "$store"; fi
fi
case "$DB_OP" in
    add)
        if DB_OP=exists awk -f "$ROOT/data/csv.awk" "$store"; then
            fail 'This book is already in your library.'
        else
            result=$?
            [[ $result == 1 ]] || fail 'Database is invalid; no changes made.'
        fi
        temp=$(mktemp "$store.tmp.XXXXXX")
        cat -- "$store" > "$temp"
        first=1
        for field in "${@:2}"; do
            field=${field//\"/\"\"}
            if ((first)); then first=0; else printf ',' >> "$temp"; fi
            printf '"%s"' "$field" >> "$temp"
        done
        printf '\n' >> "$temp"
        mv -f -- "$temp" "$store"; temp='';;
    status|rating)
        temp=$(mktemp "$store.tmp.XXXXXX")
        awk -f "$ROOT/data/csv.awk" "$store" > "$temp" || fail 'Book not found or database is invalid.'
        mv -f -- "$temp" "$store"; temp='';;
    *) awk -f "$ROOT/data/csv.awk" "$store";;
esac
