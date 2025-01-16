#!/usr/bin/env sh

export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"

BASE=$(dirname "$(readlink -f "$0")")

"$BASE/apache-ant-1.10.12/bin/ant" -buildfile "$BASE/build.xml" $*