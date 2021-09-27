#!/bin/bash

set -ex

TAGS_PREFIX="$1"

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

function getTags() {
  PREFIX=$1
  VERSION=$2
  BRANCHES=$3

  if [[ $VERSION =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    printf "${PREFIX:-latest} "
  fi
  for tag in $VERSION $BRANCHES; do
    if [[ -z "$PREFIX" || "$tag" = "$PREFIX" ]]; then
      printf "$tag "
    else
      printf "%s-%s " $PREFIX $tag
    fi
  done
}

VERSION=$(git describe --tag --dirty)
BRANCHES=$(getBranches)
TAGS=$(getTags "$TAGS_PREFIX" "$VERSION" "$BRANCHES")

echo "::set-output name=version::$VERSION"
echo "::set-output name=branches::$BRANCHES"
echo "::set-output name=tags::$TAGS"
