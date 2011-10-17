#!/bin/bash
if [ -z "$1" ]; then 
  echo usage: $0 directory "Provide a file name (without the .srt, .amr, .wav suffixes)"
   exit
fi
echo "======================================================="

echo ==Moving to backup folder
cd ../backup

echo ==Creating files _client, _server and .srt
#cp ../results/$1.3gp $1.3gp

echo ==Branching to user branch
../src/dependancies/git checkout tabletclient
../src/dependancies/git add *.srt 
../src/dependancies/git commit -m "added file $1 from user"

echo ==Branching to machinetranscription branch
../src/dependancies/git checkout laptopserver
../src/dependancies/git merge tabletclient

echo ==Converting $1.3gp video to pcm/wav $1.wav
../src/dependancies/ffmpeg -y -i $1.3gp $1.wav
#echo ==Running pocketsphinx
#echo "0:00:00.020,0:00:00.020\nResults of the machine transcription will appear below when ready.\n\n" >> $1.srt
#170word gramamr: java -jar ../src/sphinx4files/transcriber/bin/Transcriber.jar ../results/$1.wav 2>&1 | tee -a $1.srt 
#java -jar /home/gina/.groovy/lib/sphinx4/bin/LatticeDemo.jar ../results/$1.wav | grep "I heard:" | sed -e 's/I heard://' 2>&1 | tee -a $1.srt 

#cp $1.srt ../results/$1_server.srt
#cd ../src/testinstallpocketsphinx
#./hello_ps goforward.raw | grep Recognized >> ../../backup/$1
#cd ../../backup

echo "==Committing new transcripion"
#../src/dependancies/git add *.srt
#../src/dependancies/git commit -m "ran pocketsphinx on $1"

echo "==Processing prosody with Praat"
/Applications/Praat.app/Contents/MacOS/Praat /Applications/OPrimeAdministrator.app/Contents/Resources/oprime-server/src/praatfiles/praat-script-syllable-nuclei-v2file.praat -25 2 0.3 yes /Applications/OPrimeAdministrator.app/Contents/Resources/oprime-server/backup $1.wav 2>&1 | tee -a praatresults.csv

echo "==Commiting new acoustic results"
../src/dependancies/git add praatresults.csv *.TextGrid
../src/dependancies/git commit -m "ran praat on $1"

cp $1.* ../results/

echo "==Server transcription is ready."
#git checkout master #leave it in the MachineTranascription branch so that the node will copy the right version of the file into the server's response.

cd ../src

echo "==============================================================="
