# first remove all carriage returns (https://kb.iu.edu/d/acux)
#dos2unix Report.txt Report_unix.txt

awk '{ sub("\r$", ""); print }' Report.txt > Report_unix.txt