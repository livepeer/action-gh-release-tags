#!/bin/bash
set -ex

function getBranches() {
  GH_REF=${GITHUB_HEAD_REF:-$GITHUB_REF}
  if [[ $GH_REF == refs/heads/* ]]; then
    GH_REF=${GH_REF#refs/heads/}
  else
    GH_REF=$(git branch -a --points-at HEAD \
        | sed -e 's/^[\* ]*//' -e 's/^remotes\/origin\///' -e '/HEAD /d' \
        | sort | uniq)
  fi

  for branch in $GH_REF; do
    printf "$branch" | sed 's/\//-/g' | tr -cd '[:alnum:]_-'
    printf " "
  done
}

VERSION=$(git describe --tag --dirty)
BRANCHES=$(getBranches)
TAGS="$VERSION $BRANCHES"
if [[ $VERSION =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  TAGS= "latest $TAGS"
fi

echo "::set-output name=version::$VERSION"
echo "::set-output name=branches::$BRANCHES"
echo "::set-output name=tags::$TAGS"
