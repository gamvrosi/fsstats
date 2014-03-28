#!/bin/bash

awk 'BEGIN{
	occ = 0;
	cur = "";
}
{
	if (!occ) {
		occ++;
		cur = $0;
	} else {
		if (cur != $0) {
			cur = $0;
			print occ;
			occ = 1;
		} else {
			occ++;
		}
	}
}
END {
	print occ;
}'
