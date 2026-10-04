#!/usr/bin/sh

if [ -z "$1" ]; then
  echo "usage : pkg_gen.sh <PKG_ID>"
  echo "  <PKG_ID> style must be USER/PKG_NAME"
  exit
fi

PKG_ID=$1
PKG_NAME=$(basename $1)
ROOT_PATH=$(dirname $(dirname $0))
BASE_PATH="apps/$1"

echo "PKG_ID    | $PKG_ID"
echo "PKG_NAME  | $PKG_NAME"
echo "ROOT_PATH | $ROOT_PATH"
echo "BASE_PATH | $BASE_PATH"

mkdir -p "$BASE_PATH"
cp $ROOT_PATH/scripts/main.template.lua $BASE_PATH/main.lua

sed -e "s|PKG_ID|$PKG_ID|g" \
  -e "s|PKG_NAME|$PKG_NAME|g" \
  "$ROOT_PATH/scripts/manifest.template.json" >"$BASE_PATH/manifest.json"

echo "generate $PKG_ID to $BASE_PATH"
