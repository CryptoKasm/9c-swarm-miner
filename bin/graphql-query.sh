#!/bin/bash
source bin/cklib.sh
source settings.conf

if ! [ -x "$(command -v jq)" ]; then sudo apt install jq -y &> /dev/null; fi

# Queries GraphQL for NCG Balance
checkGold() {
    graphQuery=$(curl -s -X POST -H "Content-Type: application/json" --data '{"query":"\n{\n  goldBalance(address: \"'$NC_PUBLIC_KEY'\")\n}\n"}' http://localhost:23061/graphql | jq '. | {Coins: .data.goldBalance}' | tr -d \"{}) 
    echo $graphQuery
}

###############################
graphqlMain() {
    sL
}
###############################
case $1 in

  --check-gold)
    sLL
    sTitle "Nine Chronicles - Gold Balance"
    sGraphQL "$(checkGold)"
    sLL
    exit 0
    ;;

  *)
    exit 0
    ;;

esac