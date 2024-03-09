# Claas Heuer, Spetember 2015
#
# helpful: 
# http://www.grymoire.com/Unix/Awk.html#uh-1
# http://www.shellhacks.com/en/Using-BASH-Grep-OR-Grep-AND-Grep-NOT-Operators



# count number of lines
awk -F',' 'END{print NR;}' test.csv

# count number of fields
awk -F',' '{print NF;exit;}' test.csv

# print only certain columns of file and change sperator (variable: OFS)
awk -F',' 'BEGIN {OFS=":";} {print $2,$4}' test.csv

# change windows to unix file (remove carriage returns)
awk '{ sub("\r$", ""); print }' test.csv

# return lines matching one of several conditions
# 1)
grep -E "pattern1|pattern2" test.csv

# 2) 
awk '/pattern1|pattern2/' test.csv

# retunr lines matching multiple conditions
awk '/pattern1/ && /pattern2/' test.csv

# return lines that dont match pattern
# 1)
grep -v 'pattern1' test.csv
# 2)
awk '!/pattern1/' test.csv

# print only lines starting from xx and put a line number in front. $0 tells awk to print all fields
awk 'BEGIN{OFS=",";}{ if (NR > 100) {print NR, $0;}}' test.cv

# count number of unique occurences of specific field. This is like 'table' in R
 awk -F',' '{print $2}' test.csv | sort | uniq -c | sort -nr

# grep lines based on value in specific field
awk -F',' 'BEGIN{OFS=",";}{ if ($41=="SOME_VALUE") {print NR, $0;}}' test.csv

# get a substring of field. first argument = field, second = start, third = length
echo test | awk '{print substr($0,2,2);}'

# sort by column
# http://stackoverflow.com/questions/17048188/how-to-use-awk-sort-by-column-3
sort -t, -nk3 user.csv

# where

# -t, - defines your delimiter as ,.

# -n - gives you numerical sort. Added since you added it in your attempt. If your user field is text only then you dont need it.

# -k3 - defines the field (key). user is the third field.

# example: sort files by size
ls -l | sed '1d' | sed 's/ \+/,/g' | sort -t, -n -k5

# remove embeded null in strings (http://stackoverflow.com/questions/2398393/identifying-and-removing-null-characters-in-unix)
tr < file-with-nulls -d '\000' > file-without-nulls

# remove non-ASCII characters in text file (R manual problem)
# (http://stackoverflow.com/questions/3001177/how-do-i-grep-for-all-non-ascii-characters-in-unix)
grep --color='auto' -P -n '[^\x00-\x7F]' clmm.Rd



# recursive grep - highlight file and line number
grep --color='auto' -P -n  -r random .

# remove entries in second column
awk -F',' 'BEGIN {OFS=",";} {if (NR > 1) {$2 = ""}; print}}' test.csv

# list all folders and subfolders
ls -Rl | grep '^d'

# recursive sed across all files in folder and subfolders (http://stackoverflow.com/a/6759339)
find ./ -type f -exec sed -i -e 's/packAges/packages/g' {} \;
