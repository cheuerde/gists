#!/bin/bash
# Claas Heuer, October 2015
# 
# requires 'littler' - sudo apt-get install littler

function fw_to_csv {

# first argument is lines to skip if there is some meta data before the actual header
  local skip_lines=$1
  local this_file=$2

  local commas=$(echo 0 $(sed -n "$(echo $skip +2 | bc)p" $this_file| awk '{

    for (i=0; ++i < length($0);) 
      if(substr($0, i, 1) != "=" && substr($0,i+1,1) == "=") printf i"\n"    

      }' | tr '\n' ' '))

  commas=$(echo $commas $(sed -n "$(echo $skip +2 | bc)p" $this_file | awk '{print length($0);exit;}'))
  local fw=$(echo $commas | r -e 'cat(diff(scan(file=stdin(), what=numeric(0), quiet=TRUE, sep=" ")),"\n")' | sed -n '2p' | cut -d: -f2)

# change from fixed width to csv
  awk  'BEGIN{FIELDWIDTHS="'"$fw"'";OFS=",";} { $1 = $1; print;}' $this_file | sed "1,${skip}d" | sed '2d' | sed 's/ //g' 

}

# usage: fw_to_csv 6 fw_file.txt > file.csv
