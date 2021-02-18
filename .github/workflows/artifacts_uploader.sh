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

branch=`git status  | grep -Po '(?<=On branch ).*'`

echo "i'm in $branch"

if [ $branch == "develop" ]
then
    echo "upload all"
    echo "Uploading pdf files to gdrive..."
    # uploads docs
    find . -name '*.pdf' | grep -v verbale | while read file
    do
        doc=`echo $file | grep -Po '\w*(?=\.pdf)'` ; git branch -r | grep -q $doc
        if [ `echo $?` -eq 0 ]
        then 
            echo "DO NOT push $doc"
        else 
            echo "pushing $doc"
            gupload -o $file
        fi
	    
    done

    # uploads verbali
    find . -name '*.pdf' | grep verbale | while read file
    do
        doc=`echo $file | grep -Po '\w*(?=\.pdf)'` ; git branch -r | grep -q $doc
        if [ `echo $?` -eq 0 ]
        then 
            echo "DO NOT push $doc"
        else 
            echo "pushing $doc"
            gupload -o $file -r $VERBALI_FLD
        fi

    done

else
    doc=`echo $branch | cut -f2 -d '/'`
    file=`find . -name $doc.pdf`
    
    if [ ! -z $file ] #false if in branch that is not develop nor of an existing document
    then
        echo "upload $file"
        if [ `echo $file | grep -c verbale` -gt 0 ]
        then
            gupload -o $file -r $VERBALI_FLD
        else
            gupload -o $file
        fi
    fi
fi

if [ $? -eq 0 ]
then
    echo " Successfully Completed!"
else
    echo "something went wrong"
    exit 1
fi
