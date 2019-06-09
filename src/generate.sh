#!/bin/bash

set -o nounset -o errexit -o pipefail
[[ "$*" == *--debug* ]] && set -x

function generate_posts() {
    echo '# Generate posts'
    mkdir -p 'public/posts'

    local list='public/posts/list.yml'
    echo 'title: posts' > "$list"
    echo 'post:' >> "$list"
    for post in posts/*.md; do
        echo '-' >> "$list"
        echo " file: /posts/$(basename "${post%.*}.html")" >> "$list"
        sed -ne '/---/,/---/p' "$post" \
            | sed -e '1d;$d' -e 's/^/ /' \
            >> "$list"
    done
    tmp=$(mktemp)
    yq '.post |= sort_by(.date)' "$list" \
    | yq '.post |= reverse' \
    | yq '.' --yml-output \
    > "$tmp"
    mv "$tmp" "$list"

    for post in posts/*.md; do
        pandoc "$post" \
            --output="public/posts/$(basename "${post%.*}.html")" \
            --standalone --template='templates/layout.html' \
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
        --output='public/posts.html' \
        --template='templates/posts.html' \
        --metadata-file='public/posts/list.yml'

    pandoc 'pages/index.md' \
        --output='public/index.html' \
        --standalone --template='templates/layout.html' \
        --include-after-body='public/posts.html'
}

function generate_assets() {
    echo '# Generate assets'
    mkdir -p 'public'

    cp -r 'assets' 'public'
    sassc --style compressed 'assets/style.scss' 'public/assets/style.css'
}

[[ "$*" == *--clean* ]] && rm -rf 'public'

generate_posts
generate_pages
generate_assets

[[ "$*" == *--server* ]] && {
    python -m http.server 8000 \
           --bind 'localhost' \
           --directory 'public/'
}

exit 0
