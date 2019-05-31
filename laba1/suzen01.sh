#!bin/bash
ls
cat diary.txt
x=$(cat diary.txt)
echo "Flag is: ${x##*$'\n'}"
