#!/bin/bash
set -e

if [ -f "$HOME"/Documents/todo.txt ]; then
    num_of_todo="$(grep -v -c -E --null "^\s*$" "$HOME"/Documents/todo.txt || true)"

fi

# echo "Total todo: $num_of_todo"

# echo "{\"text\": \"$total_unread_mails\", \"tooltip\": \"Todo: $num_of_todo\\nLeft click: Thunderbird\\nRight click: Todo\"}"

# For sed, '$ !' excludes the last line
todo_list="$(grep -E -v "^\s*$" "$HOME"/Documents/todo.txt | head -n 15 | sed -e '$ ! s:$:\\n:' -e 's:^: :' | tr -d '\n' )"

printf '{"text": "%s", "tooltip": "%s"}' "$num_of_todo" "$todo_list"
