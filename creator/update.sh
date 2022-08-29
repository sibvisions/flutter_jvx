#!/usr/bin/env sh

BASE=$(dirname "$(readlink -f "$0")")

"$BASE/apache-ant-1.10.12/bin/ant" -buildfile "$BASE/build.xml" update