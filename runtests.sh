#! /bin/bash

[[ "$1" == "" ]] && exit 1

FOLDER=$1

FILES=$(adb shell "ls $FOLDER")

for file in ${FILES};
do
    audio=0
    video=0
    for i in {1..10}; 
    do
        result=$(adb shell "export GST_DEBUG='GST_QOS:3'; gst-launch \
            filesrc location=${FOLDER}/${file} ! queue ! \
            qtdemux name=d ! queue ! mfw_vpudecoder ! surfaceflingersink d. ! \
            queue ! mad ! audioconvert ! audioflingersink provide-clock=0" \
            | grep 'reset_qos:' | tail -n 2 | awk -Fqos:\  '{print $2}' \
            | sed s:,:: | awk '{print ($4/($4+$2))*100}')
        audio=`echo "$audio $(echo ${result} | awk '{print $1}')" | \
            awk '{print $1 + $2}'`
        video=`echo "$video $(echo ${result} | awk '{print $2}')" | \
            awk '{print $1 + $2}'`
    done
    audio=$(echo ${audio} | awk '{print $1/10}')
    video=$(echo ${video} | awk '{print $1/10}')
    echo ${file}
    echo A:${audio} V:${video}
done

