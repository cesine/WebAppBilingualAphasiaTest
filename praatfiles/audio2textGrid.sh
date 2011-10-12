#!/bin/bash
echo "======================================================="

#echo "renaming all files from mp3 to amr (as that is their real encoding)" 
#rename 's/mp3/amr/g' ./*
#cd ../trash/

for i in $@

do
stem=${i%.3gp}      # Strip off the "3gp" suffix. 
echo ==Converting video $stem.3gp to audio pcm/wav $stem.wav
#ffmpeg -y -i $stem.3gp $stem.wav
done

#echo "==Processing prosody with Praat"
praat ../src/praatfiles/praat-script-syllable-nuclei-v2dir.praat -25 2 0.1 no /home/gina/OPrime/oprime-server/backup  2>&1 | tee -a praatresults.csv


echo "==============================================================="
