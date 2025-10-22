dir=$(pwd)

echo "$dir"
echo "Start process"

if [[ "$1" == --mu1=* ]]; then
    mu1="${1#*=}"
else
    echo "Usage: $0 --mu1=VALUE"
    exit 1
fi


if [[ "$2" == --mu3=* ]]; then
    mu3="${2#*=}"
else
    echo "Usage: $0 --mu3=VALUE"
    exit 1
fi

echo "mu1 = $mu1"
echo "mu3 = $mu3"

echo "Turning xml to sdp file"
../sdpb/build/pmp2sdp 2048 -z -i "./out_g_${mu1}_${mu3}.json" -o "./out_${mu1}_${mu3}.zip"

echo "Running sdpb"
mpirun -n 128 --bind-to core --map-by core ../sdpb/build/sdpb --writeSolution="x,y,z,X,Y" --maxComplementarity=1e1000 --dualityGapThreshold=1e-30 --primalErrorThreshold=1e-30 --dualErrorThreshold=1e-30 --precision=2048 --maxIterations=50000 -s "./out_${mu1}_${mu3}.zip" -o "./out_${mu1}_${mu3}.zip_out" -c "./out_${mu1}_${mu3}.zip.ck"

rm -r "/scratch/midway3/jieda/out_${mu1}_${mu3}.zip" "/scratch/midway3/jieda/range_${mu1}_${mu3}.txt" "/scratch/midway3/jieda/out_${mu1}_${mu3}.zip_out" "/scratch/midway3/jieda/out_${mu1}_${mu3}.zip.ck"

