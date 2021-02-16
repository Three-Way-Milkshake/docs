#!/bin/bash

cd `dirname $0`

if [ $# -gt 0 ]
then
	# installs gupload utils script
	if [ $1 == "-i" ]
	then
	    echo "Installing google-driveupload script (https://github.com/labbots/google-drive-upload)..."
		./google-drive-upload/install.sh
		echo "Done."
	fi
	
	# create config using secrets
	if [ $2 == "-c" ]
	then
    	echo "configuring drive env with secrets..."
		cp drive_conf.template cnf
		sed -i "s/CID/$CID/g" cnf
		sed -i "s/CSEC/$CSEC/g" cnf
		sed -i "s/RTOKEN/$RTOKEN/g" cnf
		sed -i "s/ROOT_FLD/$ROOT_FLD/g" cnf
		mv cnf ~/.googledrive.conf
		echo "Done."
	fi
fi

cd ../../

source ~/.profile

echo "Uploading pdf files to gdrive..."
find . -name '*.pdf' | while read file
do
	gupload $file
done

echo "Completed!"
