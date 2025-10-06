#!/bin/bash
SYSROOT=$1

if [ -z "$SYSROOT" ]; then
  echo "Usage: $0 <sysroot-path>"
  exit 1
fi

echo "Fixing symlinks in $SYSROOT ..."

find "$SYSROOT" -type l | while read link; do
    target=$(readlink "$link")
    if [[ "$target" = /* ]]; then
        new_target=$(realpath --relative-to="$(dirname "$link")" "$SYSROOT$target")
        echo "$link -> $new_target"
        ln -sf "$new_target" "$link"
    fi
done

echo "Done."

