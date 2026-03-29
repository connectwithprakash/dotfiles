#!/bin/bash

# Test script to debug file selection

echo "Testing file extraction logic..."
echo ""

# Simulate what gum choose returns
test_lines=(
  "● .gitignore"
  "○ .aliases"
  "● .bash_profile"
  "━━━ Root Configuration ━━━"
  ""
)

selected_files=()

for line in "${test_lines[@]}"; do
  echo "Testing line: '$line'"

  if [[ "$line" == ●\ * ]] || [[ "$line" == ○\ * ]]; then
    echo "  ✓ Matched pattern"
    file="${line#● }"
    file="${file#○ }"
    echo "  Extracted: '$file'"
    selected_files+=("$file")
  else
    echo "  ✗ No match"
  fi
  echo ""
done

echo "Selected files count: ${#selected_files[@]}"
echo "Selected files:"
for f in "${selected_files[@]}"; do
  echo "  - '$f'"
done
