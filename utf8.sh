#!/bin/sh

#Twitt.sh A Twitter client in almost pure shell script 
#Copyright (C) 2012 Bálint Kovács alias dratini0 (dratini0@gmail.com)

byte_to_hex(){
    local high=X
    local low=Y
    case "$(($1/16))" in #higher nibble
        0|1|2|3|4|5|6|7|8|9)
            high="$(($1/16))"
            ;;
        10)
            high=A
            ;;
        11)
            high=B
            ;;
        12)
            high=C
            ;;
        13)
            high=D
            ;;
        14)
            high=E
            ;;
        15)
            high=F
            ;;
    esac
    case "$(($1%16))" in #lower nibble
        0|1|2|3|4|5|6|7|8|9)
            low="$(($1%16))"
            ;;
        10)
            low=A
            ;;
        11)
            low=B
            ;;
        12)
            low=C
            ;;
        13)
            low=D
            ;;
        14)
            low=E
            ;;
        15)
            low=F
            ;;
    esac
    echo -n "${high}${low}"
}

utf8 (){
    if [ $1 -le 127 ] ; then
        echo -n a | sed "s/a/\x$(byte_to_hex "$1")/"
        return 0
    fi
    if [ $1 -le 2047 ] ; then
        echo -n a | sed "s/a/\x$(byte_to_hex "$((192+$1/64))")\x$(byte_to_hex "$((128+$1%64))")/"
        return 0
    fi
    if [ $1 -le 65535 ] ; then
        echo -n a | sed "s/a/\x$(byte_to_hex "$((224+$1/4096))")\x$(byte_to_hex "$((128+$1/64%64))")\x$(byte_to_hex "$((128+$1%64))")/"
        return 0
    fi
    if [ $1 -le 2097151 ] ; then
        echo -n a | sed "s/a/\x$(byte_to_hex "$((240+$1/262144))")\x$(byte_to_hex "$((128+$1/4096%64))")\x$(byte_to_hex "$((128+$1/64%64))")\x$(byte_to_hex "$((128+$1%64))")/"
        return 0
    fi
}

# self tests, now obsolate
#utf8 32      #space
#utf8 47      #/
#utf8 65      #A
#utf8 368     #Ű
#utf8 65296   #０
#utf8 1053439 #􁋿
#echo
