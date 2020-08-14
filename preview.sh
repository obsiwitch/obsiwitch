#!/bin/bash

set -o errexit -o nounset

cleanup() {
    # kill subprocesses
    pkill --parent "$$"
}
trap cleanup EXIT

python -m http.server 8000 \
       --bind 'localhost' \
       --directory 'public/' &

while inotifywait \
    --recursive 'public/' 'generate.sh' 'makefile' \
    --event='modify' --event='move' \
    --event='create' --event='delete'
do
    make all
done
