#!/bin/sh
echo -ne '\033c\033]0;Taxi Driver\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Taxi Driver.x86_64" "$@"
