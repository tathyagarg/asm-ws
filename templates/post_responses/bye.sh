#!/bin/bash

FPATH="tmp/output.response"

echo "HTTP/1.1 200 OK"                > $FPATH
echo "Content-Type: application/json" >> $FPATH
echo ""                               >> $FPATH
echo "{\"message\": \"Bye\"}"         >> $FPATH
