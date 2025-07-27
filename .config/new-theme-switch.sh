#!/bin/bash

# === CONFIG ===
WALLPAPER="$1"
WAL_COLORS="$HOME/.cache/wal/colors.sh"

# === CHECK IF WALLPAPER EXISTS ===
if [ ! -f "$WALLPAPER" ]; then
  notify-send "❌ Wallpaper not found!" "$WALLPAPER"
  exit 1
fi

# === SET WALLPAPER WITH SWWW ===
swww img "$WALLPAPER" --transition-type grow --transition-fps 60 --transition-duration 0.7

# === GENERATE COLORS WITH PYWAL ===
wal -i "$WALLPAPER" -n

# === LOAD COLORS ===
if [ -f "$WAL_COLORS" ]; then
  source "$WAL_COLORS"
else
  notify-send "❌ Pywal color file not found" "$WAL_COLORS"
  exit 1
fi

# === CONVERT HEX TO RGB FOR WAYBAR ===
hex_to_rgb() {
  hex="${1/#\#}" # Remove '#' if present
  r=$((16#${hex:0:2}))
  g=$((16#${hex:2:2}))
  b=$((16#${hex:4:2}))
  echo "$r, $g, $b"
}

rgb_color1=$(hex_to_rgb "$color1")  # for crimson/red areas
rgb_color3=$(hex_to_rgb "$color3")  # for accent/highlight
rgb_color6=$(hex_to_rgb "$color6")  # for teal-ish background blocks


# === APPLY TO KITTY ===
cat > ~/.config/kitty/themes/current.conf <<EOF
background ${background}
foreground ${foreground}
cursor ${cursor}
selection_foreground ${color7}
selection_background ${color8}
color0 ${color0}
color1 ${color1}
color2 ${color2}
color3 ${color3}
color4 ${color4}
color5 ${color5}
color6 ${color6}
color7 ${color7}
color8 ${color8}
color9 ${color9}
color10 ${color10}
color11 ${color11}
color12 ${color12}
color13 ${color13}
color14 ${color14}
color15 ${color15}
EOF

# === APPLY TO FUZZEL ===
make_rgba() {
  hex=$(echo "${1//#/}" | tr '[:upper:]' '[:lower:]')
  [[ ${#hex} -eq 6 ]] && hex="${hex}ff"
  echo "$hex"
}

bg_clean=$(make_rgba "$background")
fg_clean=$(make_rgba "$foreground")
match_clean=$(make_rgba "$color2")
selection_clean=$(make_rgba "$color5")
border_clean=$(make_rgba "$color4")

cat > ~/.config/fuzzel/fuzzel.ini <<EOF
[main]
font = JetBrainsMono Nerd Font:size=12
width = 30
lines = 10

[colors]
background      = ${bg_clean}      # semi-transparent dark
text            = ${fg_clean}      # soft cyan
match           = ${match_clean}   # bright teal match highlight
selection       = ${selection_clean}   # dark teal selection bg
selection-text  = ${fg_clean}      # keep text readable
border          = ${border_clean}  # match Waybar border
EOF

# === APPLY TO WAYBAR ===
mkdir -p ~/.config/waybar/theme
cat > ~/.config/waybar/styles.css <<EOF
* {
  font-family: "JetBrainsMono Nerd Font", "Noto Sans", sans-serif;
  font-size: 12px;
  color: ${foreground};
  background: transparent;
  border: none;
}

window#waybar {
  margin: 0;
  padding: 2px 6px;
}

#workspaces button {
  background: transparent;
  color: ${foreground};
  padding: 4px 8px;
  margin: 2px;
  transition: background 0.2s ease;
  border-radius: 10px;
}

#workspaces button.focused {
  background-color: rgba(${rgb_color1}, 0.5); /* dynamic crimson-ish */
  border: 1px solid ${color1};
  font-weight: bold;
}

#clock,
#battery,
#network,
#cpu,
#memory,
#custom-player,
#custom-volume {
  padding: 4px 8px;
  margin: 2px 4px;
  background-color: rgba(${rgb_color6}, 0.2); /* dynamic teal-ish */
  border: 1px solid rgba(${rgb_color6}, 0.4);
  transition: background 0.3s ease;
  border-radius: 10px;
}

#clock {
  font-weight: 600;
  color: ${color3}; /* accent */
  background-color: rgba(${rgb_color1}, 0.25); /* reddish */
}

#battery.charging {
  color: ${color3};
}

#battery.critical {
  color: ${color1};
  font-weight: bold;
}

#network.disconnected {
  color: ${color1};
}

#custom-player:hover,
#custom-volume:hover,
#battery:hover,
#network:hover {
  background-color: rgba(${rgb_color3}, 0.2);
  border-color: rgba(${rgb_color3}, 0.6);
}
EOF

# === RELOAD WAYBAR ===
pkill waybar && waybar & disown

# === NOTIFY ===
#command -v notify-send >/dev/null && notify-send "🎨 Theme Applied" "$(basename "$WALLPAPER")"
