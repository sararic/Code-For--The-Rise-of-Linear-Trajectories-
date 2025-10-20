#!/bin/bash

if [ -f sdpb.out ]; then
    mv sdpb.out sdpb_finished.out
fi
if [ -f sdpb.err ]; then
    mv sdpb.err sdpb_finished.err
fi

if [ -f lock ]; then
    rm lock
fi

