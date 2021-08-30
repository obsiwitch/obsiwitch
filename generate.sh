#!/bin/bash

set -o errexit -o nounset

function posts_list() {
    local i; for (( i="${#@}"; i >= 1; --i )); do
        local path="${!i}"
        local title; title="$(sed -n '/^# /{s///p;q}' "$path")"
        local date; date="$(basename "${path%%_*}")"
        echo "* $date · [$title]($path)"
    done
}

posts="$(posts_list posts/*.md)" envsubst <templates/readme.md >readme.md
