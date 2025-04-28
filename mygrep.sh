#!/bin/bash

print_usage() {
  echo "Usage: $0 [options] search_string filename"
  echo "Options:"
  echo "  -n   Show line numbers"
  echo "  -v   Invert match (show non-matching lines)"
  echo "  --help  Display this help message"
}


if [[ "$1" == "--help" ]]; then
    print_usage
    exit 0
fi


if [[ $# -lt 2 ]]; then
    echo "Error: Missing arguments."
    print_usage
    exit 1
fi


show_line_numbers=false
invert_match=false

while getopts ":nv" opt; do
  case $opt in
    n)
      show_line_numbers=true
      ;;
    v)
      invert_match=true
      ;;
    \?)
      echo "Error: Invalid option -$OPTARG"
      print_usage
      exit 1
      ;;
  esac
done


shift $((OPTIND - 1))


search_string="$1"
filename="$2"

# Validate search_string and filename
if [[ -z "$search_string" ]]; then
    echo "Error: Missing search string."
    print_usage
    exit 1
fi

if [[ -z "$filename" ]]; then
    echo "Error: Missing filename."
    print_usage
    exit 1
fi

if [[ ! -f "$filename" ]]; then
    echo "Error: File '$filename' not found."
    exit 1
fi

# Read file and process
line_number=0
while IFS= read -r line; do
    line_number=$((line_number + 1))

    # Use grep to match case-insensitively
    if echo "$line" | grep -iqF "$search_string"; then
        matched=true
    else
        matched=false
    fi

    # Invert match if needed
    if $invert_match; then
        if $matched; then
            matched=false
        else
            matched=true
        fi
    fi

    if $matched; then
        if $show_line_numbers; then
            echo "${line_number}:${line}"
        else
            echo "$line"
        fi
    fi
done < "$filename"
