#!/bin/bash
# usage bash ../src/srt2touchdata.sh *.srt

cd ../backup

#subExperiment = ""
#participantCode =""
#reactionTime = ""
#stimuliNumber = ""
#touchx = ""
#touchy = ""

echo "----- Removing old files---- "
rm en*.csv
rm fr*.csv
rm particpants.csv

echo "----- Extracting data into csv ------"
for i in $@
do
  file=$i
  #1318026828633_ET1AM8RB_en28_Reading_Comprehension_for_Words.srt
  stem=${i%.srt}      # Strip off the  suffix. 
  #1318026828633_ET1AM8RB_en28_Reading_Comprehension_for_Words
  IFS=$'_'
  set $stem
  starttime=$1
  participantcode=$2
  subexperimentcode=$3 
  subexperimenttitle=${stem##*_$3_} #everythign after $3
  echo "Starttime $starttime, participant $participantcode, experimentcode $subexperimentcode, experimenttitle $subexperimenttitle"
  csvfile="$3_$subexperimentcode_$subexperimenttitle.csv"
  #Starttime 1318026828633, participant ET1AM8RB, experimentcode en28, experimenttitle Reading_Comprehension_for_Words
  unset IFS
  grep "ParticipantID" $file >tempheader
  HEADER=`cat tempheader`
  grep "ReactionTimes" $file >tempreactions
  grep "TouchResponses" $file >temptouches

  participantinfo=${HEADER##*:::===}
  echo $participantcode,$participantinfo,$starttime,$subexperimentcode >>particpants.csv


  REACTIONS=`cat tempreactions`
  reactiontimes=${REACTIONS//ReactionTimes [/$participantcode,$starttime,reaction,};
  reactiontimes=${reactiontimes// /};
  echo ${reactiontimes/]/} >> $csvfile
  
  TOUCHES=`cat temptouches`
  touchesdata=${TOUCHES//TouchResponses [/};
  touchesdata=${touchesdata//]/};

  IFS=$','
  set $touchesdata
  ys=""
  xs=""
  for t in $touchesdata
  do
    xs=$xs,${t%%:::*}
    ys=$ys,${t#*:::}
  done
  unset IFS
  echo $participantcode,$starttime,x${xs// /} >>$csvfile
  echo $participantcode,$starttime,y$ys >> $csvfile

  rm tempheader
  rm tempreactions
  rm temptouches
done



echo "==============================================================="

