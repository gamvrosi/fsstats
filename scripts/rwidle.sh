#!/bin/bash

awk -F "," '    
    BEGIN {
        getline;
        end = $2;
    }
    { 
        if ($0 ~ /FileIoRead|FileIoWrite/) {
            if ($1 > end) 
                print ($1 - end);
            if ($2 > end)
                end = $2;
        }

    }' $1
