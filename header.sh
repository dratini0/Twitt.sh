#!/bin/sh

#Twitt.sh A Twitter client in almost pure shell script 
#Copyright (C) 2012  Bálint Kovács alias dratini0 (dratini0@gmail.com)

#rundir="$(dirname $0)"
. "${rundir}/functions.sh"

screen_name="$1"

if [ "$1" = "-h" -o "$1" = "--help" -o "$0" = "-help" ]; then
    usage
    exit 0
fi

if [ "$1" = "-l" -o "$1" = "--license" ]; then
    cat <<EOF
Twitt.sh A Twitter client in almost pure shell script 
Copyright (C) 2012  Bálint Kovács alias dratini0

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
EOF
    exit 0
fi

if [ "$screen_name" = "" ]; then
    echo "Give a screen name!"
    exit 1
fi

if [ \! -d "${HOME}/.twittsh/${screen_name}" ]; then
    echo "Error: no settings and access token for this screen name! Use authenticate.sh!"
    exit 1
fi

token="$(cat "${HOME}/.twittsh/${screen_name}/token")"
token_secret="$(cat "${HOME}/.twittsh/${screen_name}/token_secret")"

