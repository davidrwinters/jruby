#!/bin/bash

# Finds files in jar archives. Works on jar files
#
# Usage: findinjars [starting_dir] <pattern>
#
# Example: findinjars ~/.m2/repository SpliceDatabase
#

if [ $# == 1 ];
 then
   startDir="."
   pattern="$1"
 else
   startDir="$1"
   pattern="$2"
fi
#echo "Args = $startDir $pattern"
find "$startDir" -name "*.jar" | xargs -I {} unzip -l {}  | grep --color=always "$pattern\|Archive\:" | grep -B1 "$pattern"
