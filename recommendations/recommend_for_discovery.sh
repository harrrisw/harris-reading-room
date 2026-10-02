#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"
library=$(bash "$DB" list)
[[ -f "$BOOK_INTERESTS_FILE" ]] || fail "Interests file not found: $BOOK_INTERESTS_FILE"
awk -F '\t' 'BEGIN {OFS="\t"}
    FILENAME==ARGV[1] {if(NF>1) genres[tolower($3)]=1; next}
    FILENAME==ARGV[2] {
        sub(/\r$/, ""); gsub(/^[ \t]+|[ \t]+$/, "")
        if(length($0) && substr($0,1,1)!="#") interests[tolower($0)]=1
        next
    }
    FNR>1 {
        familiar=(tolower($3) in genres)
        for(i in interests) if(index(tolower($3 " " $6),i)) familiar=1
        if(!familiar) print $1,$2,$3,$4,$5,50,"Discovery: explore " $3 " beyond your current shelf and interests"
    }
' <(printf '%s\n' "$library") "$BOOK_INTERESTS_FILE" "$CATALOG"
