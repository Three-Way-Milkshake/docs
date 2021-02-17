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
		#cp drive_conf.template cnf
		#sed -i 's/CID/'"${CID}"'/g' cnf
        #sed -i 's/CSEC/'"${CSEC}"'/g' cnf
        #sed -i 's/RTOKEN/'"${RTOKEN}"'/g' cnf
        #sed -i 's/ROOT_FLD/'"${ROOT_FLD}"'/g' cnf
        echo "CLIENT_ID=\"${CID}\"" > cnf
        echo "CLIENT_SECRET=\"${CSEC}\"" >> cnf
        echo "REFRESH_TOKEN=\"${RTOKEN}\"" >> cnf
        echo "ROOT_FOLDER=\"${ROOT_FLD}\"" >> cnf
		mv cnf ~/.googledrive.conf
		echo "Done."
	fi
fi

cd ../../

source ~/.profile

echo "Uploading pdf files to gdrive..."
# uploads docs
find . -name '*.pdf' | grep -v verbale | while read file
do
	gupload -o $file
done

# uploads verbali
find . -name '*.pdf' | grep verbale | while read file
do
	gupload -o $file -r $VERBALI_FLD
done

if [ $? -eq 0 ]
then
    echo " Successfully Completed!"
else
    echo "something went wrong"
    exit 1
fi
