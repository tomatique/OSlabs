#!bin/bash
echo  "Flag is: $(pwd | grep -o '[0-9a-zA-Z]\{28\}')"
