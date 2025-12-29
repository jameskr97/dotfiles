#!/bin/bash
# Notify when borgmatic backup fails

error="${1:-Backup failed}"
output="${2:-}"

message="$error"
if [[ -n "$output" ]]; then
    message="$error

Output:
$output"
fi

# Show alert dialog with full error message
osascript -e "display alert \"Borgmatic Backup Failed\" message \"$message\" as critical"
