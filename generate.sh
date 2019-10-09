#!/bin/bash

function generate_posts() {
    # generate list
    echo '# Generate list of posts'
    mkdir -p 'public/posts'

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

    # generate posts
    echo '# Generate posts'
    mkdir -p 'public/posts'

    for post in public/posts/*.md; do
        pandoc "$post" \
            --output="${post%.md}.html" \
            --template='public/templates/layout.html' \
            --toc --number-sections
    done
}

function generate_pages() {
    echo '# Generate pages'
    mkdir -p 'public'

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

generate_posts
generate_pages

[[ "$*" == *--serve* ]] && {
    python -m http.server 8000 \
           --bind 'localhost' \
           --directory 'public/'
}

exit 0
