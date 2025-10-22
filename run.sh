#!/bin/bash



# Define mu3 values

mu3l=(3.5 3.3 3 2.8 2.4 2)



# Define mu1 arrays for each mu3

declare -A mu1_map

mu1_map[3.5]="0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2"
mu1_map[3.3]="0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2"
mu1_map[3]="0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2"
mu1_map[2.8]="0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2"
mu1_map[2.4]="0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2"
mu1_map[2]="0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2"





dir=$(pwd)

echo "$dir"



for mu3 in "${mu3l[@]}"; do

    # Get the corresponding mu1 array

    mu1l=(${mu1_map[$mu3]})



    for mu1 in "${mu1l[@]}"; do

        echo "Start process: mu1=$mu1, mu3=$mu3"



        rm -r out.ck

        #rm -rf sdp.zip.ck sdp.zip_out sdp.zip division.txt result.txt



        python3 change.py "range.txt" $mu1 -1 $mu3



        echo "Generating xml file"

        wolframscript -file "gravity-supergrav-graviton.m"



        mv out.json "out_g_${mu1}_${mu3}.json"

    done

done


