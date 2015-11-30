#!/usr/bin/env bash
 for f in {.,}*;
do
  	echo "Processing $f ..."#

  	#Remove mp3 from file
  	#mv "$f" "`echo $f | sed 's/.mp3//'`"

	#Cleanup files. Cut trailing number
	newname="$(echo "$f" | cut -d_ -f2-)"
    mv "$f" "$newname"
done