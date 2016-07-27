#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1;
fi

echo "Host: $1"

HOST=$1 siege --concurrent=50 --reps=100 -f siege-urls.txt

