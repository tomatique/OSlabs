#!bin/bash
find . -type f | wc -l #check count files
rm [0-9].txt [a-z].png test-*.log
echo "Flag is: $(ls | grep -o '[0-9a-zA-Z]\{28\}')"
