#!/bin/sh

#Twitt.sh A Twitter client in almost pure shell script 
#Copyright (C) 2012  Bálint Kovács alias dratini0 (dratini0@gmail.com)

c_key="CqQNL3twKT7Jz8QlsnajYg"
c_secret="TiyzwJcmVNP0grb5eKt418iCcZg78F512GJWiI7ZuI"

rundir="$(dirname $0)"
. "${rundir}/decode_xmlentities.sh"

encode_uri_component () {
    #perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$1"
    echo "$1" | tr -d '
' | sed -f "${rundir}/percentencode.sed"
}

get_nonce () {
    cat /dev/urandom | tr -dc '[:alpha:]' | head -c 40
}

get_timestamp (){
    date '+%s'
}

if true; then #twitter apparently does not support PLAINTEXT. That would be too simple
    signmethod="HMAC-SHA1"
    sign (){
        echo -n "$1" | openssl dgst -sha1 -hmac "$2" -binary | base64
    }
 
else
    signmethod="PLAINTEXT"
    sign (){
        echo -n "$2"
    }

fi

#modified version of http://stackoverflow.com/a/7052168
read_xml (){
    local IFS=\>
    read ENTITY CONTENT
    local e=$?
    CONTENT="$(echo "$CONTENT" | tr '<' '
')"
    return $e
}

process_timeline(){

local level=0
local tag0=""
local tag1=""
local tag2=""
local tag3=""
local tweet_text="DEADBEEF"
local tweet_author="DEADBEEF"
local timeline=''
if [ "$most_recent_tweet" = "" ]; then
    most_recent_tweet=0
fi

while read_xml; do
    #echo "$ENTITY => $CONTENT"
    case $ENTITY in
        \?* | \!* | "" )
            #echo "Special tag"
            ;;
        /*)
            level=$(($level-1))
            if [ \( "$level" = "1" \) -a \( "$tag0 $tag1" = "statuses status" \) ]; then
                timeline="@${tweet_author}: ${tweet_text}
${timeline}"
            fi
            #echo "Closing tag"
            ;;
        */)
            #echo "Short \"$ENTITY\" tag"
            ;;
        *)
            case $level in
                0)
                    read tag0 sink <<EOF
$ENTITY
EOF
                    #echo 0 "$tag0" "$sink"
                    ;;
                1)
                    read tag1 sink <<EOF
$ENTITY
EOF
                    #echo 0 "$tag0" "$sink"
                    ;;
                2)
                    read tag2 sink <<EOF
$ENTITY
EOF
                    #echo 0 "$tag0" "$sink"
                    ;;
                3)
                    read tag3 sink <<EOF
$ENTITY
EOF
                    #echo 0 "$tag0" "$sink"
                    ;;
                4)
                    read tag4 sink <<EOF
$ENTITY
EOF
                    #echo 0 "$tag0" "$sink"
                    ;;
                *)
                    echo "Depth overflow!"
                    exit 1
                    ;;
            esac
            level=$(($level+1))
            #echo "\"$ENTITY\" tag, containing \"$CONTENT\""
            #echo tags "$level, $tag0, $tag1, $tag2, $tag3"
            if [ \( "$level" = "3" \) -a \( "$tag0 $tag1 $tag2" = "statuses status text" \) ]; then
                tweet_text="$(decode_xmlentities "$CONTENT")"
            fi
            if [ \( "$level" = "4" \) -a \( "$tag0 $tag1 $tag2 $tag3" = "statuses status user screen_name" \) ]; then
                tweet_author="$(decode_xmlentities "$CONTENT")"
            fi
            if [ \( "$level" = "3" \) -a \( "$tag0 $tag1 $tag2" = "statuses status id" \) ]; then
                if [ "$CONTENT" -gt "$most_recent_tweet" ]; then
                    most_recent_tweet="$CONTENT"
                    #echo $most_recent_tweet
                fi
            fi
            #echo $?
            ;;
    esac
done <<EOF
`echo -n "$1" | tr '
<' '<
'`
EOF
echo -n "$timeline"
}

#echo $most_recent_tweet

