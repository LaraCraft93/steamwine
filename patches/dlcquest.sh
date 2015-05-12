#!/bin/bash
# Lara Maia <lara@craft.net.br> 2015

env WINEPREFIX="$1" winetricks dotnet40

echo "All done."
