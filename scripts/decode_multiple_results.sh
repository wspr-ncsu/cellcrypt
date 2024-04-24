#!/bin/bash

ROOT=$PWD
FILE=${ROOT}/${1}.json

command touch $FILE
command echo '{"results":{"#select":{"tuples":{}}}' >> $FILE
command cd $1
command shopt -s globstar
EXIST=1

# while [[ $EXIST -eq 1 ]]; do
#     echo $(find $PWD -maxdepth 0 -type d | wc -l)
#     subdircount=$(find $PWD/ -maxdepth 1 -type d | wc -l)
#     if [[ subdircount -eq 1 ]]; then
#         command cd $(find $PWD/ -maxdepth 1 -type d)
#         echo `pwd`
#     else 
#         EXIST=0
#     fi
# done
i=1
echo `pwd`
for f in **/*.bqrs; do
    command echo ",\"results${i}\":" >> $FILE
    codeql bqrs decode --format=json $f >> $FILE
    i=$((i+1))
done

command echo '}' >> $FILE
    
