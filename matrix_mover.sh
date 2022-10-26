#!/usr/bin/env bash

while getopts I:i:t:o:O:h:l: flag
do
    case "${$flag}" in
        I) inputtoken=${OPTARG};;
        
        i) inputserver=${OPTARG};;
        
        O) outputtoken=${OPTARG};;
        
        t) timeout=${OPTARG};;
        
        o) outputserver=${OPTARG};;
        
        l) removerooms=true;;
        
        h) help
           exit;;
        
        \?) echo "input error"
            exit;;
        
    esac
done

rooms="$(curl --header "Authorization: Bearer ${inputtoken}" -X GET "${inputserver}/_matrix/client/v3/joined_rooms" | jq -r '.joined_rooms[]')"

for room in "$rooms" 
do
    curl --header "Authorization: Bearer ${inputtoken}" -X POST "${inputserver}/_matrix/client/v3/rooms/${room}/invite" #invite
    curl --header "Authorization: Bearer ${outputtoken}" -X POST "${outputserver}/_matrix/client/v3/join/${room}" #accept
    if [ curl --header "Authorization: Bearer ${inputtoken}" -X GET "${inputserver}/_matrix/client/v3/rooms/${room}/state/m/room.power_levels/" != 0] #check perms
    then 
    curl --header "Authorization: Bearer ${inputtoken}" -X PUT "{$inputserver}/_matrix/client/v3/rooms/"#add perms
    fi
    sleep ${timeout}
done
