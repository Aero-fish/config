#!/bin/bash
set -e

# Find number of email in inbox without the "S" (i.e., Seen) flag
num_of_unread="$(
    fd --unrestricted --full-path -tf --format "{/}" \
        --regex "inbox/(cur|new)/.*" \
        "$HOME/.local/PIM/mail/" |
        sed -E 's/^.*,([^,]*)/\1/' |
        grep --invert-match --count "S" || true
)"
[ -z "$num_of_unread" ] && num_of_unread=0
printf '{"text": "%s", "tooltip": "%s Unread mail"}' "$num_of_unread" "$num_of_unread"
