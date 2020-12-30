#!/usr/bin/env bash

set -e

wget https://gui.xmr.pm/files/block.txt -O block.txt
wget https://gui.xmr.pm/files/block_tor.txt -O block_tor.txt

git add .
date=$(date -u -Iseconds)
git commit --allow-empty -m ${date}
git push
