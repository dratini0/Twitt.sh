#!/bin/sh

#Twitt.sh A Twitter client in almost pure shell script 
#Copyright (C) 2012  Bálint Kovács alias dratini0 (dratini0@gmail.com)

rundir="$(dirname "$0")"
. "${rundir}/utf8.sh"

#modified version of http://stackoverflow.com/a/7052168
decode_xmlentities_helper(){
    local IFS='&'
    read prev entity
}

decode_xmlentities(){
    echo -n "$1;" | tr '
;' ';
' | while decode_xmlentities_helper; do
        #echo $prev $entity &>2
        echo -n "$prev"
        case "$entity" in
            '')
                echo #gets swapped to ';'
                ;;
            'quot')
                echo -n '"'
                ;;
            'lt')
                echo -n '<'
                ;;
            'gt')
                echo -n '>'
                ;;
            'amp')
                echo -n '&'
                ;;
            'apos')
                echo -n "'"
                ;;
            "#"*)
                utf8 "$(echo -n $entity | tail -c+2)"
                ;;
        esac
    done | tr '
;' ';
' | head -c -1
}