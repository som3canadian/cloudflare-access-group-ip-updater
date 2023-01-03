# cloudflare-access-group-ip-updater

## Problem Description

- Service behind zerotrust who need to access another service behind zerostrus (services are on different devices. ex: raspberry pi)
- Cannot use Cloudflare service auth built-in functionality. Created an access group base on IP address.
- The Public IP is changing (not static) (ex: your home public IP)

## Description

The goal of this script to auto update a public IP address that you use in a Cloudflare ZeroTrust Access Group. I guess you can also do it with a Workers, but it was easier for me in bash ✌️

## Requirements

- curl and jq

```bash
# mac
$ brew install jq curl
# linux
$ sudo apt install jq curl
```

- Cloudflare [Account ID](https://developers.cloudflare.com/fundamentals/get-started/basic-tasks/find-account-and-zone-ids/).
- Access Group UID (zerotrust section) with the authorize ip address. Find your public IP [here](https://ipinfo.io/).
- [Api Token](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/) with read and edit on "Access: Identity Providers and Groups" in your Account.

![Token permissions](./images/screenshot1.jpg)

![Access Group UID](./images/screenshot2.jpg)

## How to use

- git clone

```bash
git clone https://github.com/som3canadian/cloudflare-access-group-ip-updater.git
cd cloudflare-access-group-ip-updater
```

- change the variables at line 9-10-11
- make sure it works
  - At line 21-30-41 there is a commented variable for testing.
  - There is 3 line that you can uncommented for testing. Line: 21-30-41. At line 41 is to play with IP, making sure the IPs whitin the group is changing.
- setup a cron (optional)

```bash
# add cron
crontab -e
# crontab every hour (add at the end)
0 * * * * <your-path-to-repo>/cloudflare-access-group-ip-updater/cf-ip-updater.sh
```

Note: Script was made for a single IP. If you want to add more "hard coded IPs", you have to change the "changeIP" function"

Ex:

```bash
function changeIP() {
  curl -X PUT "https://api.cloudflare.com/client/v4/accounts/$accountID/access/groups/$groupUID" \
     -H "Authorization: Bearer $apiToken" \
     -H "Content-Type: application/json" \
     --data "{\"name\":\"IPs\",\"include\":[{\"ip\":{\"ip\":\"$localIP/32\"}},{\"ip\":{\"ip\":\"<your-new-ip>/32\"}}],\"exclude\":[],\"require\":[]}"
}
```
