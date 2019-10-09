#!/bin/bash

set -o nounset -o errexit -o pipefail
[[ "$*" == *--debug* ]] && set -x

function generate_lst() {
    echo '# Generate list of posts'
    mkdir -p 'public/posts'

    # generate list
    local list='public/posts/list.yml'
    echo 'title: posts' > "$list"
    echo 'post:' >> "$list"
    for post in posts/*.md; do
        echo '-' >> "$list"
        echo " path: /posts/$(basename "${post%.*}.html")" >> "$list"
        sed -ne '/---/,/---/p' "$post" \
            | sed -e '1d;$d' -e 's/^/ /' \
            >> "$list"
    done

    # sort by date
    tmp=$(mktemp)
    yq '.post |= sort_by(.date)' "$list" \
    | yq '.post |= reverse' \
    | yq '.' --yml-output \
    > "$tmp"
    mv "$tmp" "$list"
}

function generate_posts() {
    echo '# Generate posts'
    mkdir -p 'public/posts'

    for post in posts/*.md; do
        pandoc "$post" \
            --output="public/posts/$(basename "${post%.*}.html")" \
            --template='templates/layout.html' \
            --toc --number-sections
    done
}

function generate_pages() {
    echo '# Generate pages'
    mkdir -p 'public'

    [[ -f 'public/posts/list.yml' ]] || (
        mkdir -p 'public/posts'
        touch 'public/posts/list.yml'
    )
    pandoc '/dev/null' \
        --template='templates/index.html' \
        --metadata-file='public/posts/list.yml'\
        --output='public/index.html'
    pandoc '/dev/null' \
        --template='templates/layout.html' \
        --metadata='pagetitle:Index' \
        --include-after-body='public/index.html' \
        --output='public/index.html'
}

function generate_assets() {
    echo '# Generate assets'
    mkdir -p 'public'

    cp -r 'assets' 'public'
    sassc --style compressed 'assets/style.scss' 'public/assets/style.css'
}

[[ "$*" == *--clean* ]] && rm -rf 'public'

generate_lst
generate_posts
generate_pages
generate_assets

[[ "$*" == *--serve* ]] && {
    python -m http.server 8000 \
           --bind 'localhost' \
           --directory 'public/'
}

exit 0
