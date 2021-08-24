#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1
fi

flutter run --profile --no-sound-null-safety --cache-sksl --purge-persistent-cache -d $1