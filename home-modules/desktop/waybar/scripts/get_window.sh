#!/usr/bin/env bash
swaymsg -t get_tree | jq -r '.. | select(.focused? and .type=="con") | .name'