---
title: File tags
date: 2020-04-11
---

# Requirements

* File tagging tool for any file type
* Usable both from cli and gui: list, add, remove and search tags
* Tags stored in the files (no external database)

# Links

* [What's a good solution for file-tagging in linux?](https://superuser.com/questions/81563/whats-a-good-solution-for-file-tagging-in-linux)
* [Extended attributes: the good, the not so good, the bad.](https://www.lesbonscomptes.com/pages/extattrs.html)
* [Tagsistant](https://www.tagsistant.net/)

# Filename tags

After discarding a few solutions, I settled for tags in filenames in the following form: `filename.tag1.tag2.long_tag.ext`. It's simple, it does not require any specific software and it works with existing tools (e.g. ls, mv, cp, rsync, fd, fzf, file managers).  I also wrote a [script](https://gitlab.com/Obsidienne/dotfiles/-/blob/cdd67a5cfab5ad5446a020578a165efa402c4bf5/user/bin/dottags) to find all the tags used in a directory. This solution has two drawbacks though: it pollutes filenames, and filesystems have a maximum filename length (often 255 bytes).

```sh
# Example: find all tags used in a directory
$ dottags ~/Graphics/Illustrations/
[...]
25 .mp4
28 .indoors
33 .pose
43 .city
64 .shading
99 .png
165 .scene
263 .jpg
355 .character
```

```sh
# Example: fuzzy find tags
$ fzf --reverse --multi
> .character .scene .city
  69/27688 (3)
  >..f7e3dbc0f370da0c0aa9bd2b95b810286f207c8e.character.scene.3d.palace.city.jpg
  >..strations/1db5138ca81480b768727b0a45254450d8e59c72.character.scene.city.jpg
  ..ustrations/6d6c02c117eaae0e73f348ed033603dd2578d436.character.scene.city.jpg
  ..tions/9d0f1c9145156139470e231a40f0082726c59a53.character.scene.rain.city.jpg
  >..ons/32803b9ca54fca5ed9445b3644c34d4dc8db5860.character.scene.witch.city.jpg
  [...]
```
