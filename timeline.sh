#!/bin/sh

#Twitt.sh A Twitter client in almost pure shell script 
#Copyright (C) 2012  Bálint Kovács alias dratini0 (dratini0@gmail.com)

usage(){
    cat <<EOF
Usage: $0 screen-name [entries]
       $0 OPTION
Show your timeline

Options:
    -h
    --help
      Show this help message
    -l
    --license
      Show licensing and warranty information
EOF
}

rundir="$(dirname $0)"
. ${rundir}/header.sh

count=20

if [ "$2" != "" ]; then #this way, we don't have to execute the next line if this failed
    if [ "$2" -gt "0" ]; then
        count="$2"
    fi
fi

nonce="$(get_nonce)"
timestamp="$(get_timestamp)"
uri='https://api.twitter.com/statuses/home_timeline.xml'
signparam="count=$(encode_uri_component $count)&oauth_consumer_key=${c_key}&oauth_nonce=${nonce}&oauth_signature_method=${signmethod}&oauth_timestamp=${timestamp}&oauth_token=${token}&oauth_version=1.0"
#echo $signparam

signbase="GET&$(encode_uri_component "$uri")&$(encode_uri_component "$signparam")"
#echo $signbase

signkey="${c_secret}&${token_secret}"
#echo $signkey

signature=$(sign $signbase $signkey)
#echo $signature

header="OAuth oauth_consumer_key=\"${c_key}\", oauth_nonce=\"${nonce}\", oauth_signature=\"$(encode_uri_component "$signature")\", oauth_signature_method=\"${signmethod}\", oauth_timestamp=\"${timestamp}\", oauth_token=\"${token}\", oauth_version=\"1.0\""
#echo $header

get_data="count=$(encode_uri_component $count)"
#echo $post_data

response="$(wget -q -O- --header="Authorization: ${header}" "${uri}?${get_data}")"

#echo "$response"

if [ "$?" '!=' "0" ]; then
    echo "Error!"
    exit 1
fi

if [ -z "$DEBUG_RAWOUTPUT" ]; then
    process_timeline "$response"
    echo "$most_recent_tweet" > "${HOME}/.twittsh/${screen_name}/monitor_lastitem"
else
    echo "$response"
fi
