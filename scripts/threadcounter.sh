#!/bin/bash

# parallel wc on threads in passed in folder
# Folder structure folder/processname/processid/thread
folder=$1
for process in `ls $folder`
do
    for pthread in `ls $folder/$process`
    do
        #echo -ne "Starting $process($pthread)"
        for thread in `ls $folder/$process/$pthread`
        do
            wc -l $folder/$process/$pthread/$thread | awk '{ print "'$process'('$pthread'):"'$thread'" "$1 }'&
        done
    wait
    done
done
echo 

