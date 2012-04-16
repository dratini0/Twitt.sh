#!/bin/sh

rundir="$(dirname $0)"
. ${rundir}/functions.sh

response="$(cat "$rundir/xml_entities")"

process_timeline "$response"
