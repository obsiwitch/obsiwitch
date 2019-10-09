#!/bin/bash

function generate_lst() {
    echo '# Generate list of posts'

    local list='public/posts/list.yml'
    echo 'title: posts' > "$list"
    echo 'post:' >> "$list"
    for post in public/posts/*.md; do
        echo '-' >> "$list"
        echo " path: /posts/$(basename "${post%.md}").html" >> "$list"
        sed -ne '/---/,/---/p' "$post" \
            | sed -e '1d;$d' -e 's/^/ /' \
            >> "$list"
    done

    # sort list by date
    tmp=$(mktemp)
    yq '.post |= sort_by(.date)' "$list" \
    | yq '.post |= reverse' \
    | yq '.' --yml-output \
    > "$tmp"
    mv "$tmp" "$list"
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
        --template='public/templates/index.html' \
        --metadata-file='public/posts/list.yml'\
        --output='public/index.html'
    pandoc '/dev/null' \
        --template='public/templates/layout.html' \
        --metadata='pagetitle:Index' \
        --include-after-body='public/index.html' \
        --output='public/index.html'
}

function generate() {
    generate_lst
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
        --event='create' --event='delete' \
    ; do
        generate
    done
}

exit 0
