#!/usr/bin/env bash
# Integration checks use an isolated library and do not alter your saved books.
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"
temp=$(mktemp -d)
trap 'rm -rf -- "$temp"' EXIT
export BOOK_DB="$temp/library with spaces.csv"
export BOOK_INTERESTS_FILE="$temp/interests.txt"
printf 'science fiction\ntechnology\n' > "$BOOK_INTERESTS_FILE"
manage() { bash "$ROOT/workflows/manage_library.sh" "$@"; }
check() { if ! "$@"; then fail "Check failed: $*"; fi; }
reject() { if "$@" > "$temp/error" 2>&1; then fail "Expected rejection: $*"; fi; }
[[ -z "$(manage list)" ]] || fail 'New database must be empty.'
manage add Dune 'Frank Herbert' finished
manage rating Dune 'Frank Herbert' 5
check bash "$DB" exists dune 'frank herbert'
reject manage add dune 'frank herbert'
reject manage rating Dune 'Frank Herbert' 6
reject manage status Dune 'Frank Herbert' missing
reject manage status Missing Nobody reading
reject manage add '' Nobody
reject manage add $'Broken\nTitle' Nobody
[[ $(manage list | wc -l) -eq 1 ]] || fail 'Rejected writes changed storage.'
row=$(printf 'SCIENCE FICTION\n' | bash "$ROOT/books/search_books.sh")
[[ "$row" == $'Dune\tFrank Herbert\tScience Fiction\tfinished\t5\t'* ]] || fail 'Search or metadata failed.'
manage add 'A, "Quoted" Book' 'An, "Author"' owned
manage status 'A, "Quoted" Book' 'An, "Author"' reading
manage rating 'A, "Quoted" Book' 'An, "Author"' 4
row=$(manage search 'quoted')
[[ "$row" == $'A, "Quoted" Book\tAn, "Author"\tUncategorized\treading\t4\t-\tunknown' ]] || fail 'CSV quoting did not round-trip.'
printf 'PASS: persistence, quoting, metadata, search, and invalid input\n'
bash "$ROOT/workflows/get_recommendations.sh" 6 > "$temp/results" 2> "$temp/progress"
[[ $(wc -l < "$temp/results") -eq 6 ]] || fail 'Shortlist size is wrong.'
check awk -F '\t' 'NF!=7 || $1=="Dune" {bad=1} END {exit bad}' "$temp/results"
check grep -q 'Discovery:' "$temp/results"
check grep -q 'History:' "$temp/results"
# The shortlist may be dominated by history matches; verify interests separately.
bash "$ROOT/recommendations/recommend_from_interests.sh" > "$temp/interests-results"
check grep -q 'Interest:' "$temp/interests-results"
check awk -F '\t' 'NR==1 {exit !($2=="Frank Herbert" && $7 ~ /familiar author/)}' "$temp/results"
[[ $(grep -c running "$temp/progress") -eq 3 ]] || fail 'Missing progress.'
[[ $(grep -c done "$temp/progress") -eq 3 ]] || fail 'Workers did not finish.'
cat "$temp/results" "$temp/results" | bash "$ROOT/recommendations/refine_recommendations.sh" > "$temp/refined"
check cmp "$temp/results" "$temp/refined"
reject bash "$ROOT/workflows/get_recommendations.sh" 0
BOOK_INTERESTS_FILE="$temp/missing" reject bash "$ROOT/workflows/get_recommendations.sh"
printf 'PASS: parallel workflow, progress, ranking, exclusions, deduplication, and failures\n'
# Multiple independent writers must preserve all records.
pids=()
for i in 1 2 3 4; do manage add "Concurrent $i" Author & pids+=("$!"); done
for pid in "${pids[@]}"; do wait "$pid"; done
[[ $(manage list | wc -l) -eq 6 ]] || fail 'Concurrent writes lost data.'
printf 'PASS: concurrent database writes\n'
# Exercise scripts from an unrelated working directory.
(cd "$temp"; bash "$ROOT/workflows/manage_library.sh" list > /dev/null)
while IFS= read -r script; do bash -n "$script"; done < <(find "$ROOT" -name '*.sh' -not -path '*/.bin/*')
printf 'PASS: independent working directory and Bash syntax\n'
