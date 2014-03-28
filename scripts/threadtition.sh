file=$1
echo -ne "(2) Partitioning events from '$file' per thread. Progress:   0%"
total=`wc -l $file | cut -f1 -d' '`

gawk -F, 'BEGIN {
    pos = 0;
    curprog = 0;
    OFS=","
    "mkdir '$file'.trace" | getline
    close("mkdir '$file'.trace")
}

{
    # pnames, pids stores the pnames, pids for which a folder exists
    
    pos++;
    thisprog = int(pos*100/'$total');
    if (thisprog > curprog) {
            curprog = thisprog;
            printf("\b\b\b\b%3d%", curprog);
    }
    
    if ($NF == "\"\"")
            $NF="\"/\"";
    
    split($5, pid, "(");
    sub(/\)/, "", pid[2]);
    
    if (!(pid[1] in pnames)) {
            pnames[pid[1]] = 0;
            mkdircmd = "mkdir '$file'.trace/"pid[1]
            mkdircmd | getline
            close(mkdircmd);
    }
    
    if (!(pid[1]","pid[2] in pids)) {
            pids[pid[1]","pid[2]] = 0;
            mkdircmd = "mkdir '$file'.trace/"pid[1]"/"pid[2]
            mkdircmd | getline
            close(mkdircmd);
    }
    
    tfil = "'$file'.trace/"pid[1]"/"pid[2]"/"$6;
    print $0 >> tfil
    close(tfil);
}

END {
    printf("\b\b\b\bdone.  \n");
}' $file
