#!/bin/bash
echo "======================================================="

#echo "renaming all files from mp3 to amr (as that is their real encoding)" 
#rename 's/mp3/amr/g' ./*
#cd ../trash/

cd ../backup
ls

for i in $@

do
stem=${i%.3gp}      # Strip off the "3gp" suffix. 
echo ==Converting video $stem.3gp to audio pcm/wav $stem.wav
#ffmpeg -y -i $stem.3gp $stem.wav
../src/dependancies/ffmpeg -y -i $1.3gp $1.wav

done

echo "==Processing prosody with Praat"
#praat ../src/praatfiles/praat-script-syllable-nuclei-v2dir.praat -25 2 0.1 no /home/gina/OPrime/oprime-server/backup  2>&1 | tee -a praatresults.csv

/Applications/Praat.app/Contents/MacOS/Praat /Applications/OPrimeAdministrator.app/Contents/Resources/oprime-server/src/praatfiles/praat-script-syllable-nuclei-v2dir.praat -25 2 0.3 no /Applications/OPrimeAdministrator.app/Contents/Resources/oprime-server/backup  2>&1 | tee -a praatresults.csv


echo ==Branching to machinetranscription branch
../src/dependancies/git checkout laptopserver
../src/dependancies/git merge tabletclient

echo "==Commiting new acoustic results"
../src/dependancies/git add praatresults.csv *.TextGrid
../src/dependancies/git commit -m "ran praat on all files"

cp *.TextGrid ../results/


echo "==============================================================="
