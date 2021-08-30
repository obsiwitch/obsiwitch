#!/usr/bin/env python3

from pathlib import Path
from types import SimpleNamespace

def posts_list():
    posts = []
    for path in sorted(Path("posts").glob("*.md"), reverse=True):
        with path.open() as file:
            title = next( line[2:-1] for line in file
                          if line.startswith("# ") )
        date = path.name.split("_")[0]
        posts.append(SimpleNamespace(title=title, date=date, path=path))
    return posts

def readme():
    posts= "\n".join( f"* {post.date} · [{post.title}]({post.path})"
                      for post in posts_list() )
    with open("templates/readme.md") as fin, open("readme.md", "w") as fout:
        fout.write(fin.read().format(posts=posts))

readme()
