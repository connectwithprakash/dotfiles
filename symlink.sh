#!/bin/bash

# Get the directory of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Find all .symlink files in the current directory and its subdirectories
find "$DIR" -name '*.symlink' -type f | while read file; do
    # Get the filename without the .symlink extension
    filename=$(basename "$file" .symlink)

    # Create the symbolic link
    ln -s "$file" "$HOME/.$filename"
done
