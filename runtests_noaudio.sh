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
            qtdemux name=d ! queue ! mfw_vpudecoder ! surfaceflingersink" \
            | grep 'reset_qos:' | tail -n 1 | awk -Fqos:\  '{print $2}' \
            | sed s:,:: | awk '{print ($4/($4+$2))*100}')
        video=`echo "$video $(echo ${result} | awk '{print $1}')" | \
            awk '{print $1 + $2}'`
    done
    video=$(echo ${video} | awk '{print $1/10}')
    echo ${file}
    echo V:${video}
done

