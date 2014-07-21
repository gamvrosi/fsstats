fsstats
=======

scripts: 
         
         Used when organizing system trace data, most are about the MSR traces.
         The editedParseTrace your blk script for both generating the disks and 
         idle times with small updates (start time recorded in idle files now). 

rfiles: 

         The ones that remained useful over the semester are kept here. The 
         manually generated cdf scripts all take input from terminal, can be run
         with the lowercase r command.
         
data: 

         Only a subset of the data be stored on git, the rest can be found in
         /mnt/data/abdi Idle/hotness are stored in folders while the raw data is
         stored as tarballs

processed: 

         Folder contains any data collected through rfiles or awk scripts.
         All are text data containing summaries of fits or traces(mostly MSR)

plots: 

         The final set of plots and some example fits are stored here. 

filebench: 

         Data for various fileset sizes are stored in filebench_data. Each txt 
         file contains 90*proc num data points. (note for a low fileset size 
         this may not be the case due to lack of free files available)

         Process numbers vary from 1-5, threads very from 5-65 in multiples of 5

You can safely ignore anything found on c159 and anything in fs.csl's 
rfiles/scripts/plot folders as they are all either outdated or small 
modifications on the main rfiles and scripts
