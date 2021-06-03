#!/bin/bash

# dep: pandoc (templating) https://pandoc.org

set -o errexit -o nounset

function generate_list() {
    echo 'title: posts'
    echo 'post:'
    local i; for (( i="${#@}"; i >= 1; --i )); do
        local post="${!i}"
        echo "- title: $(sed -n '/^# /{s///p;q}' "$post")"
        local date; date="$(basename "${post%%_*}")"
        echo "  date: $date"
        echo "  rfcdate: $(date --rfc-email --date="$date")"
        echo "  path: $post"
    done
}

function generate_tpl() {
    pandoc '/dev/null' \
        --from='markdown' --to='plain' \
        --template="$1" --metadata-file="$2"
}

"generate_$1" "${@:2}"
