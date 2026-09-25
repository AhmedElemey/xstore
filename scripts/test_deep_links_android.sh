#!/usr/bin/env bash
# Fires each supported xStore deep-link pattern at a connected Android
# device/emulator via `adb shell am start`, bypassing App Links domain
# verification entirely — this proves the in-app routing works, not that
# a stranger's tap on a real shared link will (see
# docs_business/launch_todos/07_deep_linking.md §4 for that checklist).
#
# Requires: adb on PATH, a device/emulator attached, and the target
# package already installed on it (a dev-flavor debug build is fine).
#
# Usage:
#   scripts/test_deep_links_android.sh [-p PACKAGE] [--product ID] [--seller ID] [--order ID] [--category NAME]
#
# Defaults use placeholder ids that only prove routing (they won't
# resolve to real records) — pass real ones from your backend for a
# meaningful test, e.g.:
#   scripts/test_deep_links_android.sh --product 68d21c9c1234 --category "Home & Kitchen"
set -euo pipefail

PACKAGE="com.xstore.app.dev"
PRODUCT_ID="test-product-1"
SELLER_ID="test-seller-1"
ORDER_ID="test-order-1"
CATEGORY_NAME="Electronics"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--package) PACKAGE="$2"; shift 2 ;;
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

if ! command -v adb >/dev/null 2>&1; then
  echo "adb not found on PATH — install Android platform-tools, or run" >&2
  echo "'source scripts/android-sdk-env.sh' first if the SDK is already installed." >&2
  exit 1
fi

if ! adb get-state >/dev/null 2>&1; then
  echo "No device/emulator attached (adb get-state failed). Connect one and retry." >&2
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

fire() {
  local label="$1" uri="$2" output
  echo "==> $label: $uri"
  output="$(adb shell am start -a android.intent.action.VIEW -d "$uri" "$PACKAGE" 2>&1)"
  echo "$output"
  if grep -qi "error" <<<"$output"; then
    echo "    ^ am start reported an error — is $PACKAGE installed on this device?" >&2
  fi
  echo
}

fire "Product"  "https://xstore.com/product/${PRODUCT_ID}"
fire "Seller"   "https://xstore.com/seller/${SELLER_ID}"
fire "Order"    "https://xstore.com/order/${ORDER_ID}"
fire "Category" "https://xstore.com/category/$(urlencode "$CATEGORY_NAME")"
