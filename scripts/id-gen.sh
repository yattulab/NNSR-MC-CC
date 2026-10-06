#!/bin/sh
set -eu

company="${1:-}"

case "$company" in
[A-Z][A-Z][A-Z]) ;;
*)
  echo "usage: $0 <3-letter company code>" >&2
  exit 1
  ;;
esac

suffix="$(LC_ALL=C tr -dc 'A-Z2-7' </dev/urandom | head -c 4)"

printf '%s-%s\n' "$company" "$suffix"
