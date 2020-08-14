# [obsidienne.gitlab.io](https://obsidienne.gitlab.io)

## Dependencies

* [moreutils](https://joeyh.name/code/moreutils) (sponge)
* [inotify-tools](https://github.com/inotify-tools/inotify-tools) (inotifywait)
* [python](https://www.python.org/) (http.server)
* [pandoc](https://pandoc.org)

## Build

~~~sh
# build (-B: force rebuild)
> make [-B] [all, posts, list, feed, index]

# preview w/ automatic rebuild
> ./preview.sh
~~~
