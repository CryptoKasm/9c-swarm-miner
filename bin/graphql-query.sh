#!/bin/bash
source bin/cklib.sh
source settings.conf

# Queries GraphQL for NCG Balance
checkGold() {
    if ! [ -x "$(command -v jq)" ]; then sudo apt install jq -y &> /dev/null; fi
    graphQuery=$(curl -s -X POST -H "Content-Type: application/json" --data '{"query":"\n{\n  goldBalance(address: \"'$NC_PUBLIC_KEY'\")\n}\n"}' http://localhost:23062/graphql | jq '. | {Coins: .data.goldBalance}' | tr -d \"{}) 
    echo $graphQuery
}

###############################
graphqlMain() {
    sL
    sTitle "Nine Chronicles - Gold Balance"
    #checkGold &> /dev/null
    sGraphQL "$(checkGold)"
    sL
}
###############################
if [ "$1" == "--check-gold" ]; then
    graphqlMain
    exit 0
else
    graphqlMain
    exit 0
fi
