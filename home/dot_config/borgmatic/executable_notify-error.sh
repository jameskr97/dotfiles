#!/bin/bash
# Notify when borgmatic backup fails

error="${BORG_ERROR:-Backup failed}"
output="${BORG_OUTPUT:-}"

message="$error"
if [[ -n "$output" ]]; then
    message="$error

Output:
$output"
fi

# Show alert dialog with full error message
osascript -e "display alert \"Borgmatic Backup Failed\" message \"$message\" as critical"
