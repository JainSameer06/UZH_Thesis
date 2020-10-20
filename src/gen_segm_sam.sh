#!/bin/bash

# loop over languages
declare -a LNG=("english" "german" "indonesian")
#declare -a LNG=("armenian" "russian")

# get length of an array
arraylength=${#LNG[@]}

for (( i=1; i<${arraylength}+1; i++ ));
do
export l=${LNG[$i-1]}


# Train instructions

#loop over splits
for (( s=0; s<=9; s++ ))
do 

# loop over seeds
for (( k=0; k<=0; k++ ))
do

# Individual instruction per language/seed/training-dev-test-triple
echo ./Main_sam.sh norm $l $k $s 5 3 ensemble_test
done

done

done