#!/bin/bash

awk -F "," '/FileIoRename/{print $0}' $1
