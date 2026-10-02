#!/usr/bin/env bash
# Shared paths and validation only; no storage or UI logic.
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
DB="$ROOT/data/book_database.sh"
CATALOG="$ROOT/books/catalog.tsv"
export BOOK_INTERESTS_FILE="${BOOK_INTERESTS_FILE:-$ROOT/config/interests.txt}"
fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }
clean_field() {
    [[ "$1" != *[[:cntrl:]]* ]] || fail 'Fields must be single-line text without tabs or control characters.'
}
required() { clean_field "$1"; [[ "$1" == *[![:space:]]* ]] || fail "$2 is required."; }
