#!/usr/bin/env bash
# Fires each supported xStore deep-link pattern into a booted iOS
# Simulator via `xcrun simctl openurl` — the iOS equivalent of
# scripts/test_deep_links_android.sh's `adb shell am start`.
#
# Unlike Android, iOS has no CLI that opens an arbitrary URL on a
# *physical* device (Apple doesn't expose one, to keep Universal Link
# verification from being trivially bypassable) — for a physical
# device, paste the links this script prints into Notes or Messages
# and tap them by hand instead.
#
# Either way you need a **debug** build installed from Xcode
# (Runner.entitlements, not RunnerRelease.entitlements — the debug one
# has `?mode=developer` on its associated domains), since the
# production apple-app-site-association file doesn't exist yet. See
# docs_business/launch_todos/07_deep_linking.md §4.
#
# Usage:
#   scripts/test_deep_links_ios.sh [-s SIMULATOR] [--product ID] [--seller ID] [--order ID] [--category NAME]
#
# -s SIMULATOR: a simulator name or UDID to target (boots it if it
# isn't already running). Default: whichever simulator is currently
# booted.
set -euo pipefail

SIMULATOR=""
PRODUCT_ID="test-product-1"
SELLER_ID="test-seller-1"
ORDER_ID="test-order-1"
CATEGORY_NAME="Electronics"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--simulator) SIMULATOR="$2"; shift 2 ;;
    --product) PRODUCT_ID="$2"; shift 2 ;;
    --seller) SELLER_ID="$2"; shift 2 ;;
    --order) ORDER_ID="$2"; shift 2 ;;
    --category) CATEGORY_NAME="$2"; shift 2 ;;
    -h|--help)
      awk '/^#!/{next} /^#/{sub(/^# ?/,""); print; next} {exit}' "$0"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if ! command -v xcrun >/dev/null 2>&1; then
  echo "xcrun not found — this script needs Xcode command line tools on macOS." >&2
  exit 1
fi

# Percent-encodes everything but unreserved characters, matching what
# Uri.encodeComponent (used by routeFromDeepLinkUri for category names)
# expects on the other end.
urlencode() {
  local s="$1" out="" c hex i
  for (( i=0; i<${#s}; i++ )); do
    c="${s:i:1}"
    case "$c" in
      [a-zA-Z0-9.~_-]) out+="$c" ;;
      *) printf -v hex '%%%02X' "'$c"; out+="$hex" ;;
    esac
  done
  printf '%s' "$out"
}

LINKS=(
  "Product|https://xstore.com/product/${PRODUCT_ID}"
  "Seller|https://xstore.com/seller/${SELLER_ID}"
  "Order|https://xstore.com/order/${ORDER_ID}"
  "Category|https://xstore.com/category/$(urlencode "$CATEGORY_NAME")"
)

TARGET="${SIMULATOR:-booted}"

if [[ -n "$SIMULATOR" ]]; then
  xcrun simctl boot "$SIMULATOR" 2>/dev/null || true
fi

if [[ "$TARGET" == "booted" ]] && ! xcrun simctl list devices booted 2>/dev/null | grep -q "Booted"; then
  echo "No booted simulator found. Either:" >&2
  echo "  - pass -s '<Simulator name or UDID>' to boot one, or" >&2
  echo "  - open Simulator.app, or boot one from Xcode, first." >&2
  echo >&2
  echo "For a PHYSICAL device, simctl can't reach it at all — paste these into" >&2
  echo "Notes or Messages on the device and tap each one (needs the debug build" >&2
  echo "with mode=developer installed from Xcode):" >&2
  for entry in "${LINKS[@]}"; do
    echo "  ${entry#*|}" >&2
  done
  exit 1
fi

fire() {
  local label="$1" uri="$2" output
  echo "==> $label: $uri"
  if output="$(xcrun simctl openurl "$TARGET" "$uri" 2>&1)"; then
    [[ -n "$output" ]] && echo "$output"
  else
    echo "$output" >&2
    echo "    ^ simctl openurl failed — is the debug build (with mode=developer)" >&2
    echo "      installed on this simulator?" >&2
  fi
  echo
}

for entry in "${LINKS[@]}"; do
  fire "${entry%%|*}" "${entry#*|}"
done
