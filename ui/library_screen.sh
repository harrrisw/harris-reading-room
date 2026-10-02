#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/helpers.sh"
workflow="$ROOT/workflows/manage_library.sh"
heading 'Your library'
case "${1:-browse}" in
    add)
        title=$(gum input --header 'Book title' --placeholder 'Dune') || exit 0
        author=$(gum input --header 'Author' --placeholder 'Frank Herbert') || exit 0
        status=$(gum choose --header 'Reading status' want-to-read owned reading finished) || exit 0
        if bash "$workflow" add "$title" "$author" "$status"; then notice "Added: $title"; fi
        pause; exit 0;;
    search)
        term=$(gum input --header 'Search title, author, genre, or status' --placeholder 'science fiction') || exit 0
        rows=$(bash "$workflow" search "$term");;
    browse) rows=$(bash "$workflow" list);;
    *) fail 'Unknown library screen.';;
esac
if [[ -z "$rows" ]]; then notice 'No books found. Add a book to start your shelf.'; pause; exit 0; fi
row=$(pick_row "$rows" library) || exit 0
IFS=$'\t' read -r title author genre status rating link year <<< "$row"
heading "$title"
printf 'Author: %s\nGenre: %s\nYear: %s\nStatus: %s\nRating: %s/5 (0 = unrated)\nReference: %s\n' "$author" "$genre" "$year" "$status" "$rating" "$link"
action=$(gum choose 'Change status' 'Rate book' 'Back') || exit 0
case "$action" in
    'Change status')
        value=$(gum choose --header 'Reading status' want-to-read owned reading finished) || exit 0
        if bash "$workflow" status "$title" "$author" "$value"; then notice 'Status updated.'; fi; pause;;
    'Rate book')
        value=$(gum choose --header 'Rating: 0 clears your rating' 5 4 3 2 1 0) || exit 0
        if bash "$workflow" rating "$title" "$author" "$value"; then notice 'Rating updated.'; fi; pause;;
esac
