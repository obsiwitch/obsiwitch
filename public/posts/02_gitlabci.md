---
title: Test .gitlab-ci.yml
date: 2020-02-27
---

You can find below a simple way to test external GitLab CI/CD setups in a new
repository.

1. Create a new git repository and commit the 2 files below.
2. Execute the script with the path/URL to the repository you want to test. The
   repository's content will be copied without its history into the
   `repository/` directory and committed.
3. Push to GitLab.
4. Go back to step 2 if you want to test another setup.

~~~yml
# .gitlab-ci.yml

include: '/repository/.gitlab-ci.yml'

before_script:
    - cp -r repository/. .
~~~

~~~bash
#!/bin/bash
# run.sh

set -o errexit -o nounset

[[ "$#" -lt 1 ]] && {
    echo "Usage: $0 <local/remote repository>"
    echo "e.g. $0 file:///home/luna/Documents/Web/obsidienne.gitlab.io"
    echo "     $0 https://gitlab.com/Obsidienne/obsidienne.gitlab.io.git"
    exit 1
}

# script exits if the repository does not exist
git ls-remote "$1" > /dev/null

rm -rf 'repository'
git clone --depth=1 "$1" 'repository'
reponame=$(basename "$1")
message=$(git -C 'repository' log --format='%h %s' -1)
rm -rf 'repository/.git'
git add 'repository/'
git commit -m "$reponame - $message"
~~~
