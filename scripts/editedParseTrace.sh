#!/bin/bash

#function calc {
#        echo "scale=6; $1" | bc ;exit
#}

echo "Initiating parsing sequence..."
echo -n "1) Combining trace files... "
##./celloParser $1 > trace # Obsolete: Run ./extractTraces.sh traces, instead
#sort -n -t \t trace > sort_trace
filename=$1
disks=`cat $filename | awk -F'\t' '{print $7}' | sort | uniq`
#disks=`cat disks`
#echo -ne "" > disks
#for d in $disks
#do
#	echo $d >> disks
#done
echo "done."

echo -n "2) Partitioning data for each disk... (  0%)"
for d in $disks
do
	echo "" > disk_$d
done

total=`cat $filename | wc -l` 

awk 'BEGIN {
	pos=0
}
{
	pos=pos+1
	# printf("\b\b\b\b\b%3d%%)",pos*100/'$total')
	# enter, leave, respt, isread, bytes, offset, queue >> disk
	print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$8 >> "disk_"$7
}
END {
	printf("\b\b\b\b\b\bdone.  \n")
}' < $filename

## If the trace doesn't contain queue lengths, then run this before
## attempting to calculate idle times => NOT TESTED SINCE CODE MERGE!
#echo -ne "!) Calculating queue lengths...\n"
#for d in $disks
#do
#	echo -ne "" > queue_$1
#done
#
#for d in $disks
#do
#	filename="disk_"$d
#	echo -ne "\t"$filename" (  0%)"
#	total=`cat $filename | wc -l`
#
#	awk -F'\t' 'BEGIN {
#		pos = 0
#		lastLeave = 0
#		qLength = 0
#	}
#	{
#		pos = pos + 1
#		# At this point, we have:
#		# enter, leave, respt, isread, bytes, offset
#		enterT = $1
#		leaveT = $2
#		if (enterT < lastLeave) {
#			qLength = 1
#			if (lastLeave < leaveT)
#				lastLeave = leaveT
#		} else {
#			qLength = 0
#			lastLeave = leaveT
#		}
#		print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"qLength >> "queue_'$d'"
#	}
#	END {
#	}' $filename
#done

echo -n "3) Analyzing & calculating idle and response times...\n"

for d in $disks
do
	echo -n "" > idle_$d
	echo -n "" > resp_$d
done

for d in $disks
do
	filename="disk_"$d
	echo -n "\t"$filename" (  0%)"
	total=`cat $filename | wc -l`

	awk 'BEGIN {
		pos=0
		leave=0
	}
	{
		if (pos == 0) leave = $1
		pos = pos + 1
		idle = $1 - leave
		resp = $3
		print resp >> "resp_'$d'"
		if ($7 == 0 && idle > 0)
		{
			print $1 - idle, idle >> "idle_'$d'"
			if (idle > 10000)
				printf ("Check %d.\n", pos)
		}
		leave = $2
		printf("\b\b\b\b\b%3d%%)",pos*100/'$total')
	}
	END {
		printf("\b\b\b\b\b\bdone.  (%d)\n", pos)
	}' < $filename
done

#echo -ne "4) Analyzing & calculating interarrival times... \n"
#
#for d in $disks
#do
#	echo -ne "" > inter_$1
#done
#
#for d in $disks
#do
#	filename="disk_"$d
#	echo -ne "\t"$filename" (  0%)"
#	total=`cat $filename | wc -l`
#
#	awk 'BEGIN {
#		pos=0
#		prev=0
#	}
#	{
#		pos = pos + 1
#		arrive = $1
#		inter = arrive - prev
#		resp = $3
#		print arrive"\t"inter"\t"resp >> "inter_'$d'"
#		prev = arrive
#		printf("\b\b\b\b\b%3d%%)",pos*100/'$total')
#	}
#	END {
#		printf("\b\b\b\b\b\bdone.  (%d)\n", pos)
#	}' $filename
#done
