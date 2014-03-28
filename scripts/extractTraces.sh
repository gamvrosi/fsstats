#!/bin/bash

output=$1
echo -ne "" > $output
duration=0
#for day in {24..30} # week starting Sunday, vs. 25-31, which starts Monday
for day in {17..23}
do
	for hour in {0..23}
	do
		file=`printf "1999-10-%02d/1999-10-%02d-%02d*.ds" $day $day $hour`
		echo "Parsing $file..."
		./celloParser $duration $file >> $output
		duration=$(($duration+3600))
	done
done

#cat durations | grep Duration: | awk 'BEGIN{s=0;} {s = s+$2} END {print s}'
