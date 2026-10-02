#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/helpers.sh"
while true; do
    rainbow_heading 'Harris Reading Room'
    notice 'History, fantasy, science fiction. Familiar voices, new adventures.'
    action=$(gum choose --header 'What would you like to do?' 'Browse Library' 'Add Book' 'Search Library' 'Get Recommendations' 'View Interests' 'Quit') || exit 0
    case "$action" in
        'Browse Library') bash "$ROOT/ui/library_screen.sh" browse;;
        'Add Book') bash "$ROOT/ui/library_screen.sh" add;;
        'Search Library') bash "$ROOT/ui/library_screen.sh" search;;
        'Get Recommendations') bash "$ROOT/ui/recommendations_screen.sh";;
        'View Interests')
            heading 'Your interests'
            if [[ -f "$BOOK_INTERESTS_FILE" ]]; then cat -- "$BOOK_INTERESTS_FILE"; fi
            notice "Edit $BOOK_INTERESTS_FILE (one topic per line) to personalize suggestions."
            pause;;
        Quit) exit 0;;
    esac
done
