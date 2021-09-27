#!/bin/bash

set -ex

TAGS_PREFIX=${TAGS_PREFIX:-""}
FORCE_LATEST=${FORCE_LATEST:-false}

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
  PREFIX=$TAGS_PREFIX
  VERSION=$1
  BRANCHES=$2

  if [[ $VERSION =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ || "$FORCE_LATEST" = "true" ]]; then
    echo "${PREFIX:-latest}"
  fi
  for tag in $VERSION $BRANCHES; do
    if [[ -z "$PREFIX" || "$tag" = "$PREFIX" ]]; then
      echo "$tag"
    else
      echo "$PREFIX-$tag"
    fi
  done
}

VERSION=$(git describe --tag --dirty)
BRANCHES=$(getBranches)
TAGS=$(getTags "$VERSION" "$BRANCHES" | sort | uniq | tr '\n' ' ')

echo "::set-output name=version::$VERSION"
echo "::set-output name=branches::$BRANCHES"
echo "::set-output name=tags::$TAGS"
