#!/bin/bash

if [ $# -eq 0 ]
then
  echo "Usage : $0 [relative path]"
  exit 0
fi

for path in $*
do
  abspath=$(cd $(dirname $path) && pwd)/$(basename $path)
  echo ${abspath}
done
    
exit 0

