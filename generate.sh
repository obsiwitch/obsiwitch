#!/bin/bash

function generate_lst() {
    echo '# Generate list of posts'

    # generate yaml list
    local list='public/posts/list.yml'
    echo 'title: posts' > "$list"
    echo 'post:' >> "$list"
    for post in public/posts/*.md; do
        local metadata=$(
            echo "- path: /posts/$(basename "${post%.md}").html"
            # find 1st pattern, then print lines until 2nd pattern found
            sed -ne '/^---$/ { :loop n; /^---$/q; s/^/  /; p; b loop; }' "$post"
        )
        local hdate=$(echo "$metadata" | yq --raw-output '.[0].date')
        local rfcdate=$(date --rfc-822 --date="$hdate")
        metadata+=$'\n'"  rfcdate: $rfcdate"
        echo "$metadata" >> "$list"
    done

    # sort list by date
    yq '.post |= sort_by(.date)' "$list" \
    | yq '.post |= reverse' \
    | yq '.' --yml-output \
    | sponge "$list"
}

function generate_feed() {
    echo '# Generate feed'

    pandoc '/dev/null' \
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
