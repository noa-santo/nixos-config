#!/usr/bin/env bash

main() {
  local _output_count
  local _is_builtin
  local _named_workspace="" \
    _named_workspace_name="" \
    _named_workspace_index=""
  local -a _named_workspace_order=(
    "1:browser"
    "2:ide"
    "3:social"
    "4:terminal"
  )

  _output_count="$(niri msg outputs | grep -c "^Output" || true)"
  _is_builtin="$(niri msg outputs | grep -c "(eDP-1)" || true)"
  if ((_output_count == 1)) && ((_is_builtin == 1)); then
    for _named_workspace in "${_named_workspace_order[@]}"; do
      _named_workspace_index="${_named_workspace%%:*}"
      _named_workspace_name="${_named_workspace##*:}"
      niri msg action move-workspace-to-index "${_named_workspace_index}" \
        --reference "${_named_workspace_name}"
    done
  fi
}

main