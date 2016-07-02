#!/bin/bash
#Adapted from https://github.com/copycat-killer/dots/blob/master/bin/screenshot
#Need execute privileges for using this script

timestamp="$(date +%Y%m%d%H%M%S)"
targetbase="$HOME/Pictures/Screenshots"
output="$targetbase/$timestamp.png"
mkdir -p $targetbase
[ -d $targetbase ] || exit 1
import -window root $output