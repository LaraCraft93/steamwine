#!/bin/bash
# Lara Maia <lara@craft.net.br> 2015

env WINEPREFIX="$1" winetricks directmusic wmp10 xna40

echo "All done."
