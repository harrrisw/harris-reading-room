#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"
[[ $# == 2 ]] || fail 'Usage: fetch_book_metadata.sh TITLE AUTHOR'
required "$1" Title; required "$2" Author
# Local, curated metadata: exact title + author match, never guessed metadata.
TITLE=$1 AUTHOR=$2 awk -F '\t' 'BEGIN {OFS="\t"}
    NR>1 && tolower($1)==tolower(ENVIRON["TITLE"]) && tolower($2)==tolower(ENVIRON["AUTHOR"]) {print $1,$2,$3,$4,$5; found=1; exit}
    END {if(!found) print ENVIRON["TITLE"],ENVIRON["AUTHOR"],"Uncategorized","unknown","-"}
' "$CATALOG"
