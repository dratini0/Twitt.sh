#!/bin/sh

#Twitt.sh A Twitter client in almost pure shell script 
#Copyright (C) 2012  Bálint Kovács alias dratini0 (dratini0@gmail.com)

usage(){
    cat <<EOF
Usage: $0 screen-name
       $0 OPTION
Monitor your timeline every minute

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

if zenity="$which zenity"; then echo -n ""; else
    zenity=""
fi

display_stuff() {
    echo -n "$1"
    if [ -n "$zenity" -a -n "$1" ]; then
        zenity --notification --text="$1" &
    fi
}

if [ \( \! -f "${HOME}/.twittsh/${screen_name}/monitor_lastitem" \) -o \( \! -f "${HOME}/.twittsh/${screen_name}/monitor_history" \) ]; then
    #touch "${HOME}/.twittsh/${screen_name}/monitor_history"
    #echo -n 0 > "${HOME}/.twittsh/${screen_name}/monitor_lastitem"
    ${rundir}/timeline.sh "$screen_name" 10 > "${HOME}/.twittsh/${screen_name}/monitor_history"
fi

most_recent_tweet="$(cat "${HOME}/.twittsh/${screen_name}/monitor_lastitem")"
history="$(cat "${HOME}/.twittsh/${screen_name}/monitor_history")
"
display_stuff "$history"

while true; do
    nonce="$(get_nonce)"
    timestamp="$(get_timestamp)"
    uri='https://api.twitter.com/statuses/home_timeline.xml'
    signparam="oauth_consumer_key=${c_key}&oauth_nonce=${nonce}&oauth_signature_method=${signmethod}&oauth_timestamp=${timestamp}&oauth_token=${token}&oauth_version=1.0&since_id=$(encode_uri_component "$most_recent_tweet")"
    
    signbase="GET&$(encode_uri_component "$uri")&$(encode_uri_component "$signparam")"
    
    signkey="${c_secret}&${token_secret}"
    
    signature=$(sign $signbase $signkey)
    
    header="OAuth oauth_consumer_key=\"${c_key}\", oauth_nonce=\"${nonce}\", oauth_signature=\"$(encode_uri_component "$signature")\", oauth_signature_method=\"${signmethod}\", oauth_timestamp=\"${timestamp}\", oauth_token=\"${token}\", oauth_version=\"1.0\""

    get_data="since_id=$(encode_uri_component "$most_recent_tweet")"

    response="$(wget -q -O- --header="Authorization: ${header}" "${uri}?${get_data}" 2> /dev/null )"

    error="$?"

    if [ "$error" '!=' "0" ]; then
        echo "Error!"
        if [ -n "$DEBUG" ]; then
            echo $error
            echo "$response"
        fi
        exit 1
    fi
    
    tmp="$(mktemp)"
    process_timeline "$response" > "$tmp"
    timeline="$(cat $tmp)"
    rm "$tmp"
    
    if [ -n "$timeline" ]; then
        timeline="$timeline
"
    fi

    display_stuff "$timeline"
    
    history="$history$timeline"
    echo "$history" | tail -n 11 > "${HOME}/.twittsh/${screen_name}/monitor_history"

    echo "$most_recent_tweet" > "${HOME}/.twittsh/${screen_name}/monitor_lastitem"

    sleep 1m
done