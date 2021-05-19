#!/bin/bash

# Dependencies
# * [moreutils](https://joeyh.name/code/moreutils) (sponge)
# * [pandoc](https://pandoc.org) (template engine)

set -o errexit -o nounset

function generate_list() {
    # create
    local list='posts/list.yml'
    echo '' > "$list"

    # populate
    for post in posts/*.md; do
        echo "  title: $(sed -n '/^# /{s///p;q}' "$post")"
        local date; date="$(basename "${post%%_*}")"
        echo "  date: $date"
        echo "  rfcdate: $(date --rfc-email --date="$date")"
        echo "- path: $post"
    done >> "$list"
    echo 'post:' >> "$list"
    echo 'title: posts' >> "$list"

    # reverse
    tac "$list" | sponge "$list"
}

function generate_feed() {
    pandoc '/dev/null' \
        --from='markdown' --to='plain' \
        --template='templates/rss.xml' \
        --metadata-file='posts/list.yml'\
        --output='posts/rss.xml'
}

function generate_readme() {
    pandoc '/dev/null' \
        --from='markdown' \
        --template='templates/readme.md' \
        --metadata-file='posts/list.yml'\
        --output='readme.md'
}

if [[ "$*" == *--list* ]]; then
    generate_list
elif [[ "$*" == *--feed* ]]; then
    generate_feed
elif [[ "$*" == *--readme* ]]; then
    generate_readme
else
    exit 1
fi
