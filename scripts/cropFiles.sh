#!/bin/bash
 for f in /Users/chrislatina/Documents/GeorgiaTech/F15/MIR/FinalProject/CustomDataset/{.,}*;
do
  	echo "Processing $(basename $f) ..."

  	#Remove spaces
  	#mv "$f" `echo $f | tr ' ' '_'`;

  	# Cro file to first 30 seconds
    ffmpeg -ss 0 -t 30 -i $f /Users/chrislatina/Documents/GeorgiaTech/F15/MIR/FinalProject/ShortDataset/$(basename $f).wav

done