#!/bin/bash

# Start and end are defined in minutes
strt="$1"
end="$2"
inpf="$3"
outf="$4"

echo "Carving out $inpf trace from $strt minute to $end minute..."

awk -F, 'BEGIN {
        start = '$strt' * 60 * 10^6;
        end ='$end' * 60 * 10^6;
}
{
        # Check if we need to output
        if ($1 > start && $1 < end)
        	print $0 >> "'$outf'";

	if ($1 >= end) exit 0;
}
END {
}' $inpf
