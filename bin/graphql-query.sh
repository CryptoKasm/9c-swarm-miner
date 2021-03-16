#!/bin/bash
source bin/cklib.sh
source settings.conf

NCG_AMOUNT="2"
RECIPIENT_PUBLIC_KEY="0xc17fC5cC7df1757D656B2431B3621b42E556B523"

if ! [ -x "$(command -v jq)" ]; then sudo apt install jq -y &> /dev/null; fi

# Queries GraphQL for NCG Balance
checkGold() {
    graphQuery=$(curl -s -X POST -H "Content-Type: application/json" --data '{"query":"\n{\n  goldBalance(address: \"'$NC_PUBLIC_KEY'\")\n}\n"}' http://localhost:23061/graphql | jq '. | {Coins: .data.goldBalance}' | tr -d \"{})
    echo $graphQuery
}

# Sends mutation via GraphQL to send NCG to another player
sendGold() {
    graphQuery=$(curl -s -X POST -H "Content-Type: application/json" --data '{"query": "mutation {  transferGold(recipient: \"'0xc17fC5cC7df1757D656B2431B3621b42E556B523'\", amount: \"'2'\")}"}' http://localhost:23061/graphql | jq '. | {Coins: .data.transferGold}' | tr -d \"{})


    echo $graphQuery
}

# Check if player exists
checkPlayerID(){
    graphQuery=$(curl -s -X POST -H "Content-Type: application/json" --data '{query: stateQuery {agent(address: '0xA116d45d176aeD204a7627A470e87907e57BE6CD'){avatarAddresses}}' http://localhost:23061/graphql)


    echo $graphQuery
    #'{"query": "stateQuery \n{\n agent(address: \"'0xA116d45d176aeD204a7627A470e87907e57BE6CD'\") \n{\n avatarAddresses \n}\n"}'

}

###############################
graphqlMain() {
    sL
}
###############################
if [ "$1" == "--check-gold" ]; then
    graphqlMain
    sTitle "Nine Chronicles - Gold Balance"
    sGraphQL "$(checkGold)"
    sL
    exit 0
elif [ "$1" == "--send-gold" ]; then
    graphqlMain
    sTitle "Nine Chronicles - Sent $NCG_AMOUNT NCG to PublicID: $RECIPIENT_PUBLIC_KEY"
    sGraphQL "$(sendGold)"
    sL
    exit 0
elif [ "$1" == "--check-player" ]; then
    graphqlMain
    sTitle "Nine Chronicles - Checking Player ID"
    sGraphQL "$(checkPlayerID)"
    sL
    exit 0
else
    graphqlMain
    exit 0
fi
