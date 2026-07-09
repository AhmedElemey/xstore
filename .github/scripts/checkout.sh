#!/usr/bin/env bash
# Shallow checkout of the triggering commit (replaces actions/checkout).
set -euo pipefail

token="${GITHUB_TOKEN:?GITHUB_TOKEN is required}"
repo="${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"
host="${GITHUB_SERVER_URL#https://}"
sha="${GITHUB_SHA:?GITHUB_SHA is required}"
origin="https://x-access-token:${token}@${host}/${repo}.git"

git config --global --add safe.directory "${GITHUB_WORKSPACE}"

if [ -d .git ]; then
  git remote set-url origin "$origin"
else
  git init
  git remote add origin "$origin"
fi

git fetch --no-tags --prune --depth=1 origin "$sha"
git checkout --force FETCH_HEAD
