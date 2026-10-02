#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"
[[ $# -le 1 ]] || fail 'Usage: get_recommendations.sh [LIMIT]'
temp=$(mktemp -d)
pids=(); names=(history interests discovery)
cleanup() {
    local pid
    for pid in "${pids[@]}"; do kill "$pid" 2>/dev/null || true; done
    rm -rf -- "$temp"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
# Independent processes, separate output files, stderr reserved for progress.
for name in "${names[@]}"; do
    printf '[%s] running\n' "$name" >&2
    script="recommend_from_${name}.sh"
    [[ "$name" != discovery ]] || script=recommend_for_discovery.sh
    bash "$ROOT/recommendations/$script" > "$temp/$name.tsv" &
    pids+=("$!")
done
failed=0
for i in "${!pids[@]}"; do
    if wait "${pids[$i]}"; then
        printf '[%s] done\n' "${names[$i]}" >&2
    else
        printf '[%s] failed\n' "${names[$i]}" >&2; failed=1
    fi
done
pids=()
((failed==0)) || fail 'Recommendation generation failed; no partial shortlist was saved.'
cat "$temp/history.tsv" "$temp/interests.tsv" "$temp/discovery.tsv" |
    bash "$ROOT/recommendations/refine_recommendations.sh" "${1:-6}"
