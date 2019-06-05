#!/bin/bash

[[ "$*" == *--clean* ]] && rm -r public

mkdir -p public
cp -r assets public
sass --style compressed assets/style.scss public/assets/style.css

pandoc 'pages/index.md' \
    --output='public/index.html' \
    --standalone --template='assets/template.html'

[[ "$*" == *--debug* ]] && php -S localhost:8000 -t public/
