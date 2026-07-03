#!/usr/bin/env bash
# Resolves Android SDK build-tools for local APK verification (aapt, apksigner).
# Usage: source scripts/android-sdk-env.sh

if [[ -n "${ANDROID_HOME:-}" && -d "${ANDROID_HOME}/build-tools" ]]; then
  SDK_ROOT="$ANDROID_HOME"
elif [[ -d "${HOME}/Library/Android/sdk/build-tools" ]]; then
  SDK_ROOT="${HOME}/Library/Android/sdk"
elif [[ -d "${HOME}/Android/Sdk/build-tools" ]]; then
  SDK_ROOT="${HOME}/Android/Sdk"
else
  echo "Android SDK not found. Set ANDROID_HOME or install Android SDK." >&2
  return 1 2>/dev/null || exit 1
fi

BUILD_TOOLS_VERSION="$(ls -1 "${SDK_ROOT}/build-tools" 2>/dev/null | sort -V | tail -1)"
if [[ -z "$BUILD_TOOLS_VERSION" ]]; then
  echo "No build-tools installed under ${SDK_ROOT}/build-tools" >&2
  echo "Install with: sdkmanager \"build-tools;35.0.1\"" >&2
  return 1 2>/dev/null || exit 1
fi

export ANDROID_HOME="$SDK_ROOT"
export ANDROID_SDK_ROOT="$SDK_ROOT"
export PATH="${SDK_ROOT}/build-tools/${BUILD_TOOLS_VERSION}:${SDK_ROOT}/platform-tools:${PATH}"
