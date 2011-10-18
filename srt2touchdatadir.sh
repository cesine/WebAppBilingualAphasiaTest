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
rm en*.json
rm fr*.json
rm particpants.csv
rm touch-responses.json

echo "----- Extracting data into csv ------"
jsonfile="touch-responses.json"
echo '{"responses":[{"id":0,"x":0,"y":0,"userid":"0000","reactionTime":0,"subexperiment":"00","stimulus":0,"color":"#000000","r":3}' >> $jsonfile

FILES=../backup/*.srt
for i in $FILES
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
  #grep "ParticipantID" $file 
	#cat $file
	HEADER=`cat tempheader`
  grep "ReactionTimes" $file >tempreactions
  grep "TouchResponses" $file >temptouches

  participantinfo=${HEADER##*:::===}
  echo $participantcode,$participantinfo,$starttime,$subexperimentcode >>particpants.csv


  REACTIONS=`cat tempreactions`
  reactiontimes=${REACTIONS//ReactionTimes [/$participantcode,$starttime,reaction,};
  reactiontimes=${reactiontimes// /};
  echo ${reactiontimes/]/} >> $csvfile
  reactionarr=${REACTIONS//ReactionTimes [/}; 
  reactionarr=${reactionarr//]/};
  #echo  $reactionarr

  TOUCHES=`cat temptouches`
  touchesdata=${TOUCHES//TouchResponses [/};
  touchesdata=${touchesdata//]/};

  IFS=$', '
  arrreac=($reactionarr)
  counter=0;
  set $touchesdata
  ys=""
  xs=""
  for t in $touchesdata
  do
    echo "  ,{\"id\":0,\"x\":${t%%:::*},\"y\":${t#*:::},\"userid\":\"$participantcode\",\"reactionTime\":${arrreac[$counter]},\"subexperiment\":\"$subexperimentcode\",\"stimulus\":$counter,\"color\":\"#00ff00\",\"r\":10}" >> $jsonfile
    counter=`expr $counter + 1`;
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

echo "]}" >> $jsonfile
cp $jsonfile ../src/public/bilingualaphasiatest/touch-responses.json

echo "==============================================================="

