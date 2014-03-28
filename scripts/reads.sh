#!/bin/bash

#head -n $1 msrbuild1 | awk -F "," '/FileIoRead/{printf("Start: %d, Duration: %d, Size: %d Line: %d\n", $1, $3, strtonum($9), NR)}' 

awk -F "," '/FileIoRead/{printf("%d\n", strtonum($10))}' $1
