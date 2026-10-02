#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"
limit=${1:-6}
[[ "$limit" =~ ^[1-9][0-9]?$ ]] || fail 'Shortlist size must be 1 through 99.'
library=$(bash "$DB" list)
# Keep the strongest explanation per book, remove owned books, then rank.
# Reserve one slot for discovery so familiar matches cannot crowd it out.
awk -F '\t' 'BEGIN {OFS="\t"}
    FILENAME==ARGV[1] {owned[tolower($1) SUBSEP tolower($2)]=1; next}
    NF==7 {
        k=tolower($1) SUBSEP tolower($2)
        if(k in owned) next
        if(!(k in score) || $6+0>score[k]) {score[k]=$6+0; row[k]=$0}
    }
    END {for(k in row) print row[k]}
' <(printf '%s\n' "$library") - |
    LC_ALL=C sort -t $'\t' -k6,6nr -k1,1 -k2,2 |
    awk -F '\t' -v limit="$limit" '
        {rows[++n]=$0; if(!discovery && $7 ~ /^Discovery:/) discovery=n}
        END {
            count=(n<limit ? n : limit)
            for(i=1;i<=count;i++) {
                if(i==count && discovery>count) print rows[discovery]
                else print rows[i]
            }
        }'
