#!/bin/bash

output=$1
duration=0
#for day in {24..30} # week starting Sunday, vs. 25-31, which starts Monday
for day in 7
do
    for hour in {0..2}
    do
        hour=`expr $hour \* 8`
        echo -ne "" > $output$hour
	    file=`printf "1999-10-%02d/1999-10-%02d-%02d*.ds" $day $day $hour`
	    echo "Parsing $file..."
	    ./celloParser $duration $file >> "$output$hour"
	    duration=$(($duration+3600))
    done
done

#cat durations | grep Duration: | awk 'BEGIN{s=0;} {s = s+$2} END {print s}'
