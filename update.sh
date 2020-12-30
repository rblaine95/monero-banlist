#!/usr/bin/env bash

set -e

TIME=$(date -u +"%Y-%m-%dT%H:%M:%S+00:00")

printf "# Updated at ${TIME}\n" > block.txt
wget https://gui.xmr.pm/files/block.txt -O - >> block.txt

printf "# Updated at ${TIME}\n" > block_tor.txt
wget https://gui.xmr.pm/files/block_tor.txt -O - >> block_tor.txt

git add .
git commit --allow-empty -m ${TIME}
git push
