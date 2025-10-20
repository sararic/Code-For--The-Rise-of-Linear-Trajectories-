#!/bin/bash

#SBATCH --partition=private-dpt-cpu
##SBATCH --partition=private-dpt-bigmem
#SBATCH --job-name=sdpb
#SBATCH --output=sdpb.out
#SBATCH --error=sdpb.err
#SBATCH --mem=64000

touch lock

if [ -d sdpbIO ]; then
	rm -r sdpbIO
fi
mkdir sdpbIO

export PATH=$HOME/bin:$PATH
source /etc/profile.d/modules.sh

module load GCC/11.3.0\
 	    	OpenMPI/4.1.4\
 	    	Boost/1.79.0\
 	    	GMP/6.2.1\
 	    	MPFR/4.1.0\
 	    	libxml2/2.9.13\
 	    	RapidJSON/1.1.0\
 	    	OpenBLAS/0.3.20\
 	    	libarchive/3.6.1

python3 sdpb.py $@

./clean.sh
