#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"
export PATH="$ROOT/.bin:$PATH"
export GUM_CHOOSE_CURSOR_FOREGROUND=212 GUM_INPUT_PROMPT_FOREGROUND=212
heading() { gum style --foreground 212 --bold --border rounded --padding '1 3' "$1"; }
rainbow_heading() {
    local title=$1 colored='' character i
    local colors=(196 208 226 46 51 93 201)
    if [[ -n "${NO_COLOR:-}" ]]; then heading "$title"; return; fi
    for ((i=0;i<${#title};i++)); do
        printf -v character '\033[38;5;%sm%s' "${colors[$((i % ${#colors[@]}))]}" "${title:i:1}"
        colored+=$character
    done
    gum style --bold --border rounded --padding '1 3' "${colored}"$'\033[0m'
}
pause() { gum input --placeholder 'Press Enter to return' >/dev/null || true; }
notice() { gum style --foreground 110 "$*"; }
# Returns the original TSV record, never a parsed display label.
pick_row() {
    local rows=$1 mode=$2 labels selection number
    labels=$(printf '%s\n' "$rows" | awk -F '\t' -v mode="$mode" '{
        if(mode=="library") printf "%d. %s | %s | %s | rating %s/5\n",NR,$1,$2,$4,$5
        else printf "%d. %s | %s | %s\n",NR,$1,$2,$3
    }')
    selection=$(printf '%s\nBack\n' "$labels" | gum choose --header 'Select a book') || return 1
    [[ "$selection" != Back ]] || return 1
    number=${selection%%.*}
    printf '%s\n' "$rows" | awk -v n="$number" 'NR==n'
}
