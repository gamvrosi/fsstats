#!/bin/bash

awk -F "," '/FileIoRead|FileIoWrite/{print $0}' $1 > $1.rw 
