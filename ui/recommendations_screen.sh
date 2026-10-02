#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/helpers.sh"
heading 'Your next chapter'
notice 'Three perspectives: your history, your interests, and a little discovery.'
if ! rows=$(bash "$ROOT/workflows/get_recommendations.sh"); then pause; exit 0; fi
if [[ -z "$rows" ]]; then notice 'No new matches in the local catalog. Try new interests or extend books/catalog.tsv.'; pause; exit 0; fi
row=$(pick_row "$rows" recommendations) || exit 0
IFS=$'\t' read -r title author genre year link score reason <<< "$row"
heading "$title"
printf 'Author: %s\nGenre: %s\nYear: %s\nWhy: %s\nReference: %s\n' "$author" "$genre" "$year" "$reason" "$link"
if gum confirm 'Save to your want-to-read shelf?'; then
    if bash "$ROOT/workflows/manage_library.sh" add "$title" "$author" want-to-read; then notice 'Saved to your library.'; fi
fi
pause
