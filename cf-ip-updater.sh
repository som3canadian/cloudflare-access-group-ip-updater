#!/bin/bash

# 1. get le local ip
# 2. get current ip in our Access Group
# 3. if not the same update it

# requirement: curl and jq

accountID=""
groupUID=""
apiToken=""

function checkRequirements() {
  # 
  command -v jq >/dev/null 2>&1 || { echo "jq it's not installed.  Aborting." >&2; exit 1; }
  command -v curl >/dev/null 2>&1 || { echo "curl it's not installed.  Aborting." >&2; exit 1; }
}

function getLocalIP() {
  localIP=$(curl -X GET -s ifconfig.co/json | jq -r -M ".ip")
  #echo "$localIP"
}

function getAccessGroupIP() {
  currentGroupTEMP=$(curl -X GET -s "https://api.cloudflare.com/client/v4/accounts/$accountID/access/groups/$groupUID" \
     -H "Authorization: Bearer $apiToken" \
     -H "Content-Type: application/json" |  jq -r '.result.include[].ip.ip')
  # remove the "/32"
  currentGroupIP=$(echo "$currentGroupTEMP" | cut -d '/' -f1)
  #echo "$currentGroupIP"
}

function changeIP() {
  curl -X PUT "https://api.cloudflare.com/client/v4/accounts/$accountID/access/groups/$groupUID" \
     -H "Authorization: Bearer $apiToken" \
     -H "Content-Type: application/json" \
     --data "{\"name\":\"IPs\",\"include\":[{\"ip\":{\"ip\":\"$localIP/32\"}}],\"exclude\":[],\"require\":[]}"
}

function compareIP() {
  # localIP="1.1.1.1"
  # compare with if statement and update if not the same
  if [[ "$localIP" == "$currentGroupIP" ]]; then
    echo "IP are the same, nothing to do"
    exit 0
  else
    echo "IP NOT the same, we will update it"
    changeIP
  fi
}

function doAction() {
  checkRequirements
  getLocalIP
  getAccessGroupIP
  compareIP
}
doAction