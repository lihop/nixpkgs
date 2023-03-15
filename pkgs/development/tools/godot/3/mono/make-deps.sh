#!/usr/bin/env bash
nix-shell ../../../../../../ -A godot-mono.make-deps --run 'eval "$makeDeps"'
