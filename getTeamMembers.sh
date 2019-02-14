#!/bin/bash

accessToken="bc5dd45216c8548b571f9fdc81bdaebd94b63eb4"

usage()
{
    echo "usage: getTeamMembers:
         -o --organization         for organization name
         -n --team-name            for team name
         -i --team-id              for team id
         -t --access-token         for access token
        
         requires team id or team and organization name"
}

while [ "$1" != "" ]; do
    case $1 in
        -o | --organization )    shift
                                 organizationName=$1
                                 ;;
        -n | --team-name )       shift
                                 teamName=$1
                                 ;;
        -i | --team-id )         shift
                                 teamId=$1
                                 ;;
        -t | --access-token )    shift
                                 accessToken=$1
                                 ;;
        -h | --help )            usage
                                 exit
                                 ;;
        * )                      usage
                                 exit 1
    esac
    shift
done

if [ -z "$teamId" ]
then
    echo "Searching team id in organization $organizationName with name $teamName..."
    teamId=$(curl --silent -H "Accept: application/vnd.github.v3+json" -H "Authorization: token bc5dd45216c8548b571f9fdc81bdaebd94b63eb4" \
    -i https://api.github.com/orgs/$organizationName/teams | grep "^\s*\"name\": \"$teamName\"" -A 1 | \
    grep "^\s*\"id\":" | sed -e "s/^\s*\"id\": \(.*\),/\1/g")
    if [ -z "$teamId" ]
    then
        echo "Team was not found"
        exit 0
    fi
    echo "Target team id was found: $teamId"
fi

echo "Getting members for team with id $teamId:"
curl --silent -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $accessToken" \
     -i https://api.github.com/teams/$teamId/members  | grep "^\s*\"login\":" | sed -e "s/^\s*\"login\": \"\(.*\)\",/\1/g"
