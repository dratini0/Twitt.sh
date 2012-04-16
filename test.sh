#!/bin/sh

c_key="CqQNL3twKT7Jz8QlsnajYg"
c_secret="TiyzwJcmVNP0grb5eKt418iCcZg78F512GJWiI7ZuI"

rundir="$(dirname $0)"
screen_name="$1"

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

sign (){
    echo -n "$1" | openssl dgst -sha1 -hmac "$2" -binary | base64
}

#modified version of http://stackoverflow.com/a/7052168
read_xml (){
    local IFS=\>
    read ENTITY CONTENT
    local e=$?
    CONTENT="$(echo "$CONTENT" | tr '<' '
')"
    return $e
}

if [ \! -d "${HOME}/.twittsh/${screen_name}" ]; then
    echo "Error: no access token for this screen name! Use authenticate.sh!"
    exit 1
fi

token="$(cat "${HOME}/.twittsh/${screen_name}/token")"
token_secret="$(cat "${HOME}/.twittsh/${screen_name}/token_secret")"

nonce="$(get_nonce)"
timestamp="$(get_timestamp)"
uri='https://api.twitter.com/statuses/home_timeline.xml'
signparam="oauth_consumer_key=${c_key}&oauth_nonce=${nonce}&oauth_signature_method=HMAC-SHA1&oauth_timestamp=${timestamp}&oauth_token=${token}&oauth_version=1.0"
#echo $signparam

signbase="GET&$(encode_uri_component "$uri")&$(encode_uri_component "$signparam")"
#echo $signbase

signkey="${c_secret}&${token_secret}"
#echo $signkey

signature=$(sign $signbase $signkey)
#echo $signature

header="OAuth oauth_consumer_key=\"${c_key}\", oauth_nonce=\"${nonce}\", oauth_signature=\"$(encode_uri_component "$signature")\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"${timestamp}\", oauth_token=\"${token}\", oauth_version=\"1.0\""
#echo $header

post_data=""
#echo $post_data

response="$(wget -q -O- --header="Authorization: ${header}" "${uri}")"
#echo $?
#echo "$response"

#echo "$response"

level=0
tag0=""
tag1=""
tag2=""
tag3=""
tweet_text="DEADBEEF"
tweet_author="DEADBEEF"
most_recent_tweet=0

while read_xml; do
    #echo "$ENTITY => $CONTENT"
    case $ENTITY in
        \?* | \!* | "" )
            #echo "Special tag"
            ;;
        /*)
            level=$(($level-1))
            if [ \( "$level" = "1" \) -a \( "$tag0 $tag1" = "statuses status" \) ]; then
                echo "@${tweet_author}: ${tweet_text}"
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
                tweet_text="$CONTENT"
            fi
            if [ \( "$level" = "4" \) -a \( "$tag0 $tag1 $tag2 $tag3" = "statuses status user screen_name" \) ]; then
                tweet_author="$CONTENT"
            fi
            if [ \( "$level" = "3" \) -a \( "$tag0 $tag1 $tag2" = "statuses status id" \) ]; then
                if [ "$CONTENT" -gt "$most_recent_tweet" ]; then
                    most_recent_tweet="$CONTENT"
                    echo $most_recent_tweet
                fi
            fi
            #echo $?
            ;;
    esac
done <<EOF
`echo -n "$response" | tr '
<' '<
'`
EOF

#echo $most_recent_tweet

