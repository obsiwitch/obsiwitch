#!/bin/bash

set -o errexit -o nounset

function generate_list() {
    echo '# Generate list of posts'

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
    echo '# Generate feed'

    pandoc '/dev/null' \
        --from='markdown' --to='plain' \
        --template='public/templates/rss.xml' \
        --metadata-file='public/posts/list.yml'\
        --output='public/rss.xml'
}

function generate_posts() {
    echo '# Generate posts'

    for post in public/posts/*.md; do
        pandoc "$post" \
            --output="${post%.md}.html" \
            --template='public/templates/layout.html' \
            --toc --number-sections
    done
}

function generate_pages() {
    echo '# Generate pages'

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

function generate() {
    generate_list
    generate_feed
    generate_posts
    generate_pages
}

function serve() {
    python -m http.server 8000 \
           --bind 'localhost' \
           --directory 'public/'
}

generate

[[ "$*" == *--preview* ]] && {
    serve &
    while inotifywait \
        --recursive 'public/' \
        --event='modify' --event='move' \
        --event='create' --event='delete'
    do
        generate
    done
}

exit 0
