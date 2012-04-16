#!/bin/sh

#Twitt.sh A Twitter client in almost pure shell script 
#Copyright (C) 2012  Bálint Kovács alias dratini0 (dratini0@gmail.com)

usage(){
    cat <<EOF
Usage: $0 [OPTION]
Get an access token for the other scripts

Options:
    -h
    --help
      Show this help message
    -l
    --license
      Show licensing and warranty information
EOF
}

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

rundir="$(dirname $0)"
. ${rundir}/functions.sh

if [ \! -d .twittsh ] ; then
    mkdir ~/.twittsh
    chmod go-rwx ~/.twittsh 
fi

nonce="$(get_nonce)"
timestamp="$(get_timestamp)"
uri='https://api.twitter.com/oauth/request_token'
signparam="oauth_callback=oob&oauth_consumer_key=${c_key}&oauth_nonce=${nonce}&oauth_signature_method=HMAC-SHA1&oauth_timestamp=${timestamp}&oauth_version=1.0"
#echo $signparam

signbase="POST&$(encode_uri_component "$uri")&$(encode_uri_component "$signparam")"
#echo $signbase

signkey="${c_secret}&"
#echo $signkey

signature=$(sign $signbase $signkey)
#echo $signature

header="OAuth oauth_consumer_key=\"${c_key}\", oauth_nonce=\"${nonce}\", oauth_callback=\"oob\", oauth_signature=\"$(encode_uri_component "$signature")\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"${timestamp}\", oauth_version=\"1.0\""
#echo $header

response="$(wget -q --post-data= -O- --header="Authorization: ${header}" "${uri}")"
#echo $?
#echo "$response"
for i in $(echo -n "$response" | sed "s/&/\n/g"); do
    case $i in
        oauth_token=*)
            token="$(echo -n "$i" | tail -c +13)"
            #echo $token
            ;;
        oauth_token_secret=*)
            token_secret="$(echo -n "$i" | tail -c +20)"
            #echo $token_secret
            ;;
    esac
done

if [ -z "$token" -o -z "$token_secret" ]; then
    echo "Error! It might be a network error or something else."
    exit 1
fi

echo "Visit https://api.twitter.com/oauth/authorize?oauth_token=${token}"
echo -n "Enter the PIN here: "
read pin

nonce="$(get_nonce)"
timestamp="$(get_timestamp)"
uri='https://api.twitter.com/oauth/access_token'
signparam="oauth_consumer_key=${c_key}&oauth_nonce=${nonce}&oauth_signature_method=HMAC-SHA1&oauth_timestamp=${timestamp}&oauth_token=${token}&oauth_verifier=$(encode_uri_component "$pin")&oauth_version=1.0"
#echo $signparam

signbase="POST&$(encode_uri_component "$uri")&$(encode_uri_component "$signparam")"
#echo $signbase

signkey="${c_secret}&${token_secret}"
#echo $signkey

signature=$(sign $signbase $signkey)
#echo $signature

header="OAuth oauth_consumer_key=\"${c_key}\", oauth_nonce=\"${nonce}\", oauth_signature=\"$(encode_uri_component "$signature")\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"${timestamp}\", oauth_token=\"${token}\", oauth_verifier=\"$(encode_uri_component "$pin")\", oauth_version=\"1.0\""
#echo $header

post_data=""
#echo $post_data

response="$(wget -q --post-data="$post_data" -O- --header="Authorization: ${header}" "${uri}")"
#echo $?
#echo $response

for i in $(echo -n "$response" | sed "s/&/\n/g"); do
    case $i in
        oauth_token=*)
            token="$(echo -n "$i" | tail -c +13)"
            #echo $token | tee ~/.twittsh/token
            ;;
        oauth_token_secret=*)
            token_secret="$(echo -n "$i" | tail -c +20)"
            #echo $token_secret | tee ~/.twittsh/token_secret
            ;;
        screen_name=*)
            screen_name="$(echo -n "$i" | tail -c +13)"
            #echo "Welcome, ${screen_name}!"
    esac
done

if [ -z "$token" -o -z "$token_secret" -o -z "$screen_name" ]; then
    echo "Error! You may have entered the pin incorrectly."
    exit 1
fi

echo "Welcome, ${screen_name}!"

if [ \! -d "$HOME/.twittsh/${screen_name}" ] ; then
    mkdir "$HOME/.twittsh/${screen_name}"
    chmod go-rwx "$HOME/.twittsh/${screen_name}"
fi

echo "$token" > "$HOME/.twittsh/${screen_name}/token"
chmod go-rwx "$HOME/.twittsh/${screen_name}/token"
echo "$token_secret" > "$HOME/.twittsh/${screen_name}/token_secret"
chmod go-rwx "$HOME/.twittsh/${screen_name}/token_secret"

