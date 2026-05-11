killall -q -9 waybar || true
killall -q -9 swaync || true

swaync &
waybar &
