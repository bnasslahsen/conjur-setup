# Demo script for conjur setup

## Pre-requisites
- Minimum conjur 13.x binary uploaded to the target servers
- conjur-cli
- docker or podman installed
- Clone this git repository

## Create Conjur Master
- Go to scrips directory:
```shell
cd scripts
```
- Then run:
```shell
./create-leader.sh
```
- Check master health:
```shell
curl -k https://$(hostname -f)/health
```

## Load sample policy
- Go to polcies directory:
```shell
cd policies
```
- You need Conjur-CLI installed, then Run:
```shell
conjur policy load -b root -f app.yaml
```