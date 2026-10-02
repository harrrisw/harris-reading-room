#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"
library=$(bash "$DB" list)
awk -F '\t' 'BEGIN {OFS="\t"}
    FILENAME==ARGV[1] {
        # Saved books count; highly rated or finished books count more.
        if($5>0 && $5<3) next
        weight=1+($4=="finished")+($5>=4)
        genres[tolower($3)]+=weight; authors[tolower($2)]+=weight; next
    }
    FNR>1 {
        g=genres[tolower($3)]; a=authors[tolower($2)]
        # Familiar authors get a stronger vote than genre similarity (15 vs 3).
        reason=(a>0 ? "History: familiar author - " $2 : "History: matches a saved or enjoyed genre")
        if(g+a>0) print $1,$2,$3,$4,$5,60+g*3+a*15,reason
    }
' <(printf '%s\n' "$library") "$CATALOG"
