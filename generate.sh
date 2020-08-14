#!/bin/bash

set -o errexit -o nounset

function generate_list() {
    # create
    local list='public/posts/list.yml'
    echo '' > "$list"

    # populate
    for post in public/posts/*.md; do
        local metadata; metadata=$(
            # find 1st pattern, then print lines until 2nd pattern found
            sed -ne '/^---$/ { :loop n; /^---$/q; s/^/  /; p; b loop; }' "$post"
        )
        local hdate; hdate=$(sed -n 's/  date\: //p ' <<< "$metadata")
        local rfcdate; rfcdate=$(date --rfc-email --date="$hdate")
        metadata+=$'\n'"  rfcdate: $rfcdate"
        metadata+=$'\n'"- path: /posts/$(basename "${post%.md}").html"
        echo "$metadata" >> "$list"
    done
    echo 'post:' >> "$list"
    echo 'title: posts' >> "$list"

    # reverse
    tac "$list" | sponge "$list"
}

function generate_feed() {
    pandoc '/dev/null' \
        --from='markdown' --to='plain' \
        --template='public/templates/rss.xml' \
        --metadata-file='public/posts/list.yml'\
        --output='public/rss.xml'
}

function generate_post() {
    pandoc "$1" \
        --output="${1%.md}.html" \
        --template='public/templates/layout.html' \
        --toc --number-sections
}

function generate_index() {
    pandoc '/dev/null' \
        --from='markdown' \
        --template='public/templates/index.html' \
        --metadata-file='public/posts/list.yml'\
        --output='public/index.html'
    pandoc '/dev/null' \
        --from='markdown' \
        --template='public/templates/layout.html' \
        --metadata='pagetitle:Index' \
        --include-after-body='public/index.html' \
        --output='public/index.html'
}

if [[ "$*" == *--post* ]]; then
    generate_post "$2"
elif [[ "$*" == *--list* ]]; then
    generate_list
elif [[ "$*" == *--feed* ]]; then
    generate_feed
elif [[ "$*" == *--index* ]]; then
    generate_index
else
    exit 1
fi
