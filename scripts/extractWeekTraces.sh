#!/bin/bash

output=$1
duration=0
#for day in {24..30} # week starting Sunday, vs. 25-31, which starts Monday
for week in 1 21 
do
    echo -ne "" > "$output$week"
    wend=`expr $week + 7`
    for day in $(seq $week $wend)
        do
	    for hour in {0..23}
	    do
		    file=`printf "1999-10-%02d/1999-10-%02d-%02d*.ds" $day $day $hour`
		    echo "Parsing $file..."
		    ./celloParser $duration $file >> "$output$week"
		    duration=$(($duration+3600))
	    done
    done
done

#cat durations | grep Duration: | awk 'BEGIN{s=0;} {s = s+$2} END {print s}'
