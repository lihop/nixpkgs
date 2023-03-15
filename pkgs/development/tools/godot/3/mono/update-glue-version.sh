#! /usr/bin/env nix-shell
#! nix-shell -i bash -p steam-run unzip wget

# This script updates the hard-coded glue_version in gen_cs_glue_version.py.patch by pulling it from
# the official build. See that file for details around why this exists.

set -e

[ -z "$1" ] && echo "Godot version not specified. Exiting." && exit 1

gdversion=$1

# Download and extract the official stable 64-bit X11 mono build of Godot.
gddir="$(mktemp -d)"
trap 'rm -rf -- "$gddir"' EXIT
wget -P "$gddir" https://downloads.tuxfamily.org/godotengine/$gdversion/mono/Godot_v$gdversion-stable_mono_x11_64.zip
unzip "$gddir"/Godot_v$gdversion-stable_mono_x11_64.zip -d "$gddir"

# Generate the mono glue from the official build.
gluedir="$(mktemp -d)"
trap 'rm -rf -- "$gluedir"' EXIT
steam-run "$gddir"/Godot_v$gdversion-stable_mono_x11_64/Godot_v$gdversion-stable_mono_x11.64 --generate-mono-glue "$gluedir"

# Extract the glue version.
glueversion=$(grep -Po '(?<=get_cs_glue_version\(\) \{ return )[0-9]+(?=; \})' "$gluedir"/mono_glue.gen.cpp)

# Update the patch with the obtained glue version.
sed -i "s/^+    glue_version = [0-9]\+$/+    glue_version = $glueversion/" ./gen_cs_glue_version.py.patch

echo "Updated gen_cs_glue_version.py.patch with glue_version: $glueversion"
