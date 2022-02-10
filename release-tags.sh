#!/bin/bash

set -ex

TAGS_PREFIX=${TAGS_PREFIX:-""}
FORCE_LATEST=${FORCE_LATEST:-false}
ALWAYS_LATEST_ON_BRANCH=${ALWAYS_LATEST_ON_BRANCH:-""}

function getBranches() {
  local gh_ref=${GITHUB_HEAD_REF:-$GITHUB_REF}
  if [[ $gh_ref == refs/heads/* ]]; then
    gh_ref=${gh_ref#refs/heads/}
  else
    gh_ref=$(git branch -a --points-at HEAD | sed -e 's/^[\* ]*//;s:^remotes/origin/::;/HEAD /d' | sort -u)
  fi

  for branch in $gh_ref; do
    printf "$branch" | sed 's:/:-:g' | tr -cd '[:alnum:]_-'
    printf " "
  done
}

function getTags() {
  local prefix=$TAGS_PREFIX
  local version=$1
  local branches=$2

  for branch in $branches; do
    if [[ "$branch" = "$ALWAYS_LATEST_ON_BRANCH" ]]; then
      FORCE_LATEST="true"
    fi
  done

  if [[ $version =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ || "$FORCE_LATEST" = "true" ]]; then
    echo "${prefix:-latest}"
  fi
  for tag in $version $branches; do
    if [[ -z "$prefix" || "$tag" = "$prefix" ]]; then
      echo "$tag"
    else
      echo "${prefix}-${tag}"
    fi
  done
}

VERSION=$(git describe --tag --dirty)
BRANCHES=$(getBranches)
TAGS=$(getTags "$VERSION" "$BRANCHES" | sort -u | tr '\n' ' ')

echo "::set-output name=version::$VERSION"
echo "::set-output name=branches::$BRANCHES"
echo "::set-output name=tags::$TAGS"
