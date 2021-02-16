#!/bin/bash

cd `dirname $0`

if [ $# -gt 0 ]
then
	# installs gupload utils script
	if [ $1 == "-i" ]
	then
		./google-drive-upload/install.sh
	fi
	
	# create config using secrets
	if [ $2 == "-c" ]
	then
		cp drive_conf.template cnf
		sed -i "s/CID/$CID/" cnf
		sed -i "s/CSEC/$CSEC/" cnf
		sed -i "s/RTOKEN/$RTOKEN/" cnf
		sed -i "s/ROOT_FLD/$ROOT_FLD/" cnf
		mv cnf ~/.googledrive.conf
	fi
fi

cd ../../

find . -name '*.pdf' | while read file
do
	gupload $file
done
