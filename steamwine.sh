#!/bin/bash
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#   Lara Maia <lara@craft.net.br> 2015
#

STEAMWINE_PREFIX="/home/lara/.local/share/wineprefixes/steam"
STEAMWINE_PATH="$STEAMWINE_PREFIX/drive_c/Program Files/Steam"
STEAMWINE_APPS="$STEAMWINE_PATH/steamapps"
STEAMWINE_GAMES="$STEAMWINE_PATH/steamapps/common"

function help() {
    local game=

    printf "\nUse: $0 %23c execute steam client trough wine\n\n"
    printf "%5c $0 --reinstall %11c delete all steam files and related games\n"
    printf "%43c and reinstall local steam client\n\n"
    printf "%5c $0 --safereinstall %7c reinstall local steamwine client\n"
    printf "%43c but keep downloaded games in library\n\n"
    printf "%5c $0 --relink %14c relink games library into $HOME\n\n"
    printf "%5c ========= GAMES PATCHES =========\n\n"

    for file in $(ls patches/*)
    do
        game="$(basename -zs '.sh' $file)"
        printf "%5c $0 --$game %$[20-${#game}]c apply wine patches for $game\n"
    done
    echo
    unset game
}

function call() {
    exec patches/$1 $STEAMWINE_PREFIX
    exit $?
}

function link() {
    if test ! -L "$STEAMWINE_APPS" -o ! -d "$HOME"/.steamapps
    then
        mkdir -p "$HOME"/.steamapps || exit 1
        
        if test -d "$STEAMWINE_APPS"
        then
            cp -rf "$STEAMWINE_APPS"/* "$HOME"/.steamapps/ || exit 1
            rm -rf "$STEAMWINE_APPS" || exit 1
        fi
    
        rm -rf "$HOME"/steamgames
        ln -s "$HOME"/.steamapps/ "$STEAMWINE_APPS" || exit 1
        ln -s "$HOME"/.steamapps/common "$HOME"/steamgames || exit
    fi
}

function install() {
    rm -rf "$STEAMWINE_PREFIX"
    env WINEARCH=win32 WINEPREFIX="$STEAMWINE_PREFIX" winetricks --no-isolate --force steam
    link
    exit 0
}


for file in $(ls patches/*)
do
    if test "$1" == "--$(basename -zs '.sh' $file)"
    then
        call $(basename $file)
        break
    fi
done

case "$1" in
    --relink)
        test -L "$STEAMWINE_APPS" && unlink "$STEAMWINE_APPS"
        shift
        break
        ;;
    --reinstall|--safereinstall)
        test "$1" == "--reinstall" && rm -rf "$HOME"/{.steamapps/,steamgames}
        install
        break
        ;;

    *)  if test ! -f "$STEAMWINE_PATH/Steam.exe"
        then
            install
        fi

        if test "$1" != ""
        then
            help
            exit 1
        fi

        link
       ;;
esac

env WINEPREFIX="$STEAMWINE_PREFIX" wine "$STEAMWINE_PATH/Steam.exe"
