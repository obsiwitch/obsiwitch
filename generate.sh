#!/bin/bash

# Dependencies
# * [moreutils](https://joeyh.name/code/moreutils) (sponge)
# * [pandoc](https://pandoc.org) (template engine)

set -o errexit -o nounset

function generate_list() {
    { for post in "$@"; do
        echo "  title: $(sed -n '/^# /{s///p;q}' "$post")"
        local date; date="$(basename "${post%%_*}")"
        echo "  date: $date"
        echo "  rfcdate: $(date --rfc-email --date="$date")"
        echo "- path: $post"
    done
    echo 'post:'
    echo 'title: posts'; } | tac
}

function generate_tpl() {
    pandoc '/dev/null' \
        --from='markdown' --to='plain' \
        --template="$1" --metadata-file="$2"
}

"generate_$1" "${@:2}"
