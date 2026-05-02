for _ in {1..5}; do
  if text_output=$(curl -s "https://wttr.in/$1?format=1"); then
    text=$(echo "$text_output" | sed -E "s/\s+/ /g")
    if tooltip_output=$(curl -s "https://wttr.in/$1?format=4"); then
      tooltip=$(echo "$tooltip_output" | sed -E "s/\s+/ /g")
      jq -n --arg text "$text" --arg tooltip "$tooltip" '{text: $text, tooltip: $tooltip}'
      exit
    fi
  fi

  sleep 2
done
echo "{\"text\":\"error\", \"tooltip\":\"error\"}"
