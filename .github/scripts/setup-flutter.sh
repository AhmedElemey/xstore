#!/usr/bin/env bash
# Install a pinned Flutter SDK from github.com/flutter/flutter.
set -euo pipefail

flutter_version="${1:?Flutter version required}"
precache_target="${2:-}"

flutter_root="${RUNNER_TOOL_CACHE}/flutter-${flutter_version}"
if [ ! -x "${flutter_root}/bin/flutter" ]; then
  git clone https://github.com/flutter/flutter.git \
    --depth 1 \
    --branch "${flutter_version}" \
    "${flutter_root}"
fi

echo "${flutter_root}/bin" >> "${GITHUB_PATH}"
"${flutter_root}/bin/flutter" config --no-analytics
"${flutter_root}/bin/flutter" --version

if [ -n "${precache_target}" ]; then
  "${flutter_root}/bin/flutter" precache --"${precache_target}"
fi
