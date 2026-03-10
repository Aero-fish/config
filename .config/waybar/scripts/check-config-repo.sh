#!/bin/bash
set -e
## Return 0 if there is an update

cd "$HOME/.backup/config/shared_github" || exit 1
if ! git fetch; then
        printf '{"text":"%s", "tooltip": "%s"}' " " "Cannot fetch repo"
        exit 0
fi

# if [ -n "$(git status --porcelain)" ]; then
#         git stash >/dev/null 2>&1
#         stashed="stashed"
# fi

# # Update the repo. Swallow the error
# git pull >/dev/null 2>&1 || true

if [ -n "$(git status --porcelain)" ] ||
        git status -uno | grep -Eq "(is behind|is ahead)"; then
        printf '{"text":"%s", "tooltip": "%s"}' " " "Config has local modifications"
else
        printf '{"text":"%s", "tooltip": "%s"}' " " "Config is up to date with repo"
fi
