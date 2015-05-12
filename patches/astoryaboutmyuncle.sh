#!/bin/bash
# Lara Maia <lara@craft.net.br> 2015

env WINEPREFIX="$1" winetricks dotnet40 vcrun2010 directx9

echo "This game works better with CSMT Patches"

echo "All done."
