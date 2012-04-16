#!/bin/sh

#Twitt.sh A Twitter client in almost pure shell script 
#Copyright (C) 2012  Bálint Kovács alias dratini0

usage(){
    cat <<EOF
Usage: $0 screen-name tweet
       $0 OPTION
Update your Twitter status

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
. "${rundir}/header.sh"

if [ -z "$2" ]; then
    echo "You did not give a tweet text!"
else
    status="$2"
fi

token="$(cat "${HOME}/.twittsh/${screen_name}/token")"
token_secret="$(cat "${HOME}/.twittsh/${screen_name}/token_secret")"

nonce="$(get_nonce)"
timestamp="$(get_timestamp)"
uri='https://api.twitter.com/statuses/update.xml'
signparam="oauth_consumer_key=${c_key}&oauth_nonce=${nonce}&oauth_signature_method=${signmethod}&oauth_timestamp=${timestamp}&oauth_token=${token}&oauth_version=1.0&status=$(encode_uri_component "$status")"
#echo $signparam

signbase="POST&$(encode_uri_component "$uri")&$(encode_uri_component "$signparam")"
#echo $signbase

signkey="${c_secret}&${token_secret}"
#echo $signkey

signature="$(sign $signbase $signkey)"
#echo $signature

header="OAuth oauth_consumer_key=\"${c_key}\", oauth_nonce=\"${nonce}\", oauth_signature=\"$(encode_uri_component "$signature")\", oauth_signature_method=\"${signmethod}\", oauth_timestamp=\"${timestamp}\", oauth_token=\"${token}\", oauth_version=\"1.0\""
#echo $header

post_data="status=$(encode_uri_component "$status")"
#echo $post_data

wget -q -O- --post-data="$post_data" --header="Authorization: ${header}" "${uri}"

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


