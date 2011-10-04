#! /bin/bash

FILENAME=$1
FRAMESIZES="hd1080 hd720 hd480"
VCODEC="libx264"
BITRATES="2M 4M 8M 12M 14M 20M"

[[ "$1" == "" ]] && exit 1

[[ "${FILENAME/original/}" == "${FILENAME}" ]] && exit 1

for RES in ${FRAMESIZES};
do
    for BR in ${BITRATES}; 
    do
        OUTPUT=${FILENAME/original/${RES}_${BR}_mp3_2ch_192k}
        ffmpeg -y -i ${FILENAME} -b $BR -bt $BR -vcodec libx264 -pass 1 -s $RES \
            -vpre fastfirstpass -an ${OUTPUT} &&
        ffmpeg -y -i ${FILENAME} -b $BR -bt $BR -vcodec libx264 -pass 2 -s $RES \
            -vpre hq -acodec libmp3lame -ac 2 -ar 48000 -ab 192k ${OUTPUT}
    done
done
#    -acodec libfaac -ac 2 -ar 48000 -ab 192k output.mp4


