#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"
[[ -f "$BOOK_INTERESTS_FILE" ]] || fail "Interests file not found: $BOOK_INTERESTS_FILE"
awk -F '\t' 'BEGIN {OFS="\t"}
    FILENAME==ARGV[1] {
        sub(/\r$/, ""); gsub(/^[ \t]+|[ \t]+$/, "")
        if(length($0) && substr($0,1,1)!="#") interests[tolower($0)]=1
        next
    }
    FNR>1 {
        n=0; reason=""
        for(i in interests) if(index(tolower($3 " " $6),i)) {n++; if(reason=="" || i<reason) reason=i}
        if(n) print $1,$2,$3,$4,$5,55+n*5,"Interest: " reason
    }
' "$BOOK_INTERESTS_FILE" "$CATALOG"
