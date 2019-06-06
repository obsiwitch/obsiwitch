---
title: Fuzzy bash completion
date: 2019-06-02
---

# Introduction

[Fzf](https://github.com/junegunn/fzf) is a command-line fuzzy finder.
Some scripts are shipped with fzf to add [keybindings](https://github.com/junegunn/fzf#key-bindings-for-command-line)
and [fuzzy completion](https://github.com/junegunn/fzf#fuzzy-completion-for-bash-and-zsh)
to a shell. To use them in bash you can source them in your `~/.bashrc`.

The [bash fuzzy completion script](https://github.com/junegunn/fzf/blob/0030d184481686384676537857614977e1fd2f94/shell/completion.bash)
first saves existing completion specifications, e.g. functions
defined by the [bash-completion](https://github.com/scop/bash-completion)
package. Then, it replaces the original specifications with new ones using the
[complete](https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion-Builtins.html)
builtin (e.g. `complete -F _fzf_path_completion cd`).

If the `**` trigger sequence is found, fuzzy completion is used (e.g. `cd
../**<TAB>`). Else, the original completion function for the corresponding
command is used (e.g. `cd <TAB>`).

Doing things this way means only a few commands support fuzzy completion, and
other commands need to be added [manually](https://github.com/junegunn/fzf#supported-commands)
using complete.

# Script

I wanted fuzzy path completion for every commands and to keep the ability to
call the default bash completion, so I wrote my own script.

I could not use the complete builtin with a completion function since we saw
it forces us to write a specification for each command we want to use. I
could not access the [`COMP_*`](https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html#index-COMP_005fCWORD)
shell variables inside my script either. Keybindings in bash are created using the
[bind](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-bind)
builtin. We can bind our own shell command using `bind -x '"keyseq":
"shell-command"'`. Binding a shell function this way gives us access to the
`READLINE_LINE` and `READLINE_POINT` variables inside it, allowing us to access
the line currently typed in the shell without using the `COMP_*`
variables.

<blockquote>
```
READLINE_LINE
    The contents of the readline line buffer, for use with "bind -x"
    (see SHELL BUILTIN COMMANDS below).

READLINE_POINT
    The position of the insertion point in the readline line buffer,
    for use with "bind -x" (see SHELL BUILTIN COMMANDS below).
```
[Bash Reference manual - Shell Variables](https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html#index-READLINE_005fLINE)
</blockquote>

I also needed to find a way to call readline's completion without having to
manually call a completion function. To do this we can bind the complete
readline function to the `\e[0n` key sequence (VT100 ANSI escape sequence for
`Response: terminal is OK`). Then we print `\e[5n` (VT100 ANSI escape sequence
for `Device status report`). The terminal then answers with `\e[0n`, which in
turns activates readline's completion. [[1]](https://unix.stackexchange.com/a/217390)

You can find below a minimal version of the script. The full version is
available [here](https://gitlab.com/Obsidienne/dotfiles/blob/6b4c389cf62b62d4fc3448586480c1cc58c3419a/cli/shell/fzf.sh).

```sh
# Minimal fuzzy completion on trigger sequence '@', else use readline's
# completion.
function _fzf_complete() {
    local words=( ${READLINE_LINE:0:$READLINE_POINT} )
    local remainder=( ${READLINE_LINE:$READLINE_POINT} )

    if [[ "${words[-1]:0:1}" != '@' ]]; then
        bind '"\e[0n": complete'; printf '\e[5n'
        return
    fi
    unset 'words[-1]'

    local selected=$(
        fd . --print0 \
        | fzf --reverse --multi --read0 --print0 --exit-0 \
        | xargs -0 --no-run-if-empty printf '%q '
    )
    [[ -z "$selected" ]] && return

    READLINE_LINE="${words[*]} ${selected}${remainder[*]}"
    READLINE_POINT=$(( $READLINE_POINT + ${#selected} ))
}

# bind _fzf_complete to <TAB>
bind -x '"\C-i": "_fzf_complete"'
```
