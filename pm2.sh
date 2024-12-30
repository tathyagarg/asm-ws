#!/bin/bash

NAME="asm-ws"

pm2 delete $NAME
echo "Deleted $NAME"

pm2 start make --name $NAME
pm2 save

echo "Started $NAME"

