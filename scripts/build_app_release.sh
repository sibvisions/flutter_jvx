#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1
fi

if [ $# -eq 1 ]
  then
    echo "Only 1 argument supplied"
    exit 1
fi

if [ $# -eq 2 ]
  then
    echo "Building Flutter client"

    echo "Version $1+$2"

    flutter build apk --release --no-sound-null-safety --dart-define=PROD=true --build-name=$1 --build-number=$2
fi
