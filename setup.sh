#!/bin/bash
cd ../oprime-server
mv ../oprime-transcription-lite src
#mkdir practicetemp
#cd practicetemp

mkdir results
echo "This folder holds your results for completed experiments. " >results/experiment_results_are_in_this_folder
mkdir backup
echo "This folder contains a backup of all your results, including incomplete experiments. It is using Git to version everything so even if you change a file, you can always undo the changes." >backup/this_has_hidden_versioning
mkdir logs

# set up git in the backup folder
cd backup
git init
git config user.name "OPrime Laptop Server Instance"
git config user.email "oprimeinstance@laptop"
git remote add github git@github.com:iLanguage/oprime-bilingualaphasiatest-opendata.git
echo "*.3gp\n*.mp3" > .gitignore
git add .gitignore
git commit -m "SetupScript: just ran"
git push github master
git branch tabletclient
git branch laptopserver
git branch laptopclient
git branch trash

