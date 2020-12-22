#!/bin/bash

set -o errexit -o nounset

trap 'pkill --parent "$$"' EXIT # kill subprocesses

python -m http.server --bind 'localhost' --directory 'public/' &

while inotifywait --event='create,delete,modify,move' --recursive \
    'public/' 'generate.sh' 'makefile'
do
    make all
done
