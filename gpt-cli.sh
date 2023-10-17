#!/usr/bin/env bash

base_api="https://api.nova-oss.com/v1/chat/completions"

model="gpt-3.5-turbo"

api_key_store="${XDG_CONFIG_HOME:-"$HOME/.config/"}.gpt"

if ! test -f "$api_key_store"; then
    echo "Missing api key"
    read -r -p "Write api key here: " api_key_input
    touch "$api_key_store"
    echo "$api_key_input" > "$api_key_store"
fi
read -r api_key < "$api_key_store"
query_text="$*"

if [ $# -eq 0 ]; 
then
    read -r -p "Write your query here: " query_text
fi

echo "$query_text"

result=$(curl "$base_api" \
    --no-progress-meter \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $api_key" \
    -d "{
        \"model\": \"$model\",
        \"messages\": [{\"role\": \"user\", \"content\": \"$query_text\"}]
    }")

OUT="$(mktemp)"

printf "$(echo $result | jq '.choices[0].message.content' | sed 's/^"//;s/"$//')" > "$OUT"

echo

mdcat "$OUT"

rm "$OUT"
