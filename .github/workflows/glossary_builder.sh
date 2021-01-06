#!/bin/bash

cd `dirname $0`
cd ../../

for doc in `find . -name glossario.txt`
do 
	#go to the root of the doc
	cd `dirname $doc` 
	#do the job
	#if [ ! -e glossario.tex ]
	#then
		echo -e '\usepackage[toc,acronym]{glossaries}\n\makeglossaries\n' > glossario.tex
	#fi

	#madeChangings=false

	cat glossario.txt | sort -r | while read line
	do
		type=`echo $line | cut -f1 -d ':'`
		key=`echo $line | cut -f2 -d ':'`
		if [ "$type" == "G" ]
		then
			# glossario
			sing=`echo $line | cut -f3 -d ':'`
			plur=`echo $line | cut -f4 -d ':'`
			mean=`echo $line | cut -f5 -d ':'`
			if [ `grep -c "newglossaryentry{$key}" glossario.tex` -lt 1 ]
			then
				echo "missing G: $key, adding it"
				
				if [ "$plur" == "X" ]
				then
					echo -e "\\\newglossaryentry{$key}{name={$sing},%\n\tdescription={$mean}}\n" >> glossario.tex
				else
					echo -e "\\\newglossaryentry{$key}{name={$sing}, plural={$plur},%\n\tdescription={$mean}}\n" >> glossario.tex
				fi
			fi
			
			if [ "$plur" != "X" ]
			then
				#plural replace
				echo "checking $plur occurrencies..."
				for f in `grep -ril "$plur" | grep '\.tex' | grep -v glossario`
				do
					# lookbehind needed (?<!gls{)
					#perl -i -p -e "s/(?<!(ls|pl|rt)\{)$plur(?!{)/\\\glspl{$key}\\\textsubscript{G}/gi" $f
					#perl -i -p -e "s/(?<!(ls\{|pl\{|rt\{|[a-z]{3}))$plur(?!\{)/\\\glspl{$key}\\\textsubscript{G}/g" $f
					perl -i -p -e "s/(?<=\s)$plur(?=\s|\.|\:|,)/\\\glspl{$key}\\\textsubscript{G}/g" $f
					echo "found in $f"
					#cat $f | perl -p -e "s/(?<!gls{)$plur/\\\glspl{$key}/g"
				done
			fi
			
			#singular replace
			echo "checking $sing occurrencies..."
			for f in `grep -ril "$sing" | grep '\.tex' | grep -v glossario`
			do
				# lookbehind needed (?<!gls{)
				#perl -i -p -e "s/(?<!(ls|pl|rt)\{)$sing(?!{)/\\\gls{$key}\\\textsubscript{G}/gi" $f
				#perl -i -p -e "s/(?<!(ls\{|pl\{|rt\{|[a-z]{3}))$sing(?!\{)/\\\gls{$key}\\\textsubscript{G}/g" $f
				perl -i -p -e "s/(?<=\s)$sing(?=\s|\.|\:|,)/\\\gls{$key}\\\textsubscript{G}/g" $f
				echo "found in $f"
				#cat $f | perl -p -e "s/(?<!gls{)$sing/\\\gls{$key}/g"
			done
			
		elif [ "$type" == "A" ]
		then
			# acronimo
			short=`echo $line | cut -f3 -d ':'`
			long=`echo $line | cut -f4 -d ':'`
			if [ `grep -c "newacronym{$key" glossario.tex` -lt 1 ]
			then
				echo "missing A: $key, adding it"
				echo -e "\\\newacronym{$key}{$short}{$long}\n" >> glossario.tex
			fi
			
			#replace
			echo "checking $short occurencies..."
			for f in `grep -ril "$short" | grep '\.tex' | grep -v glossario`
			do
				#(?<!(ls\{|pl\{|rt\{|[a-z]{3}))$WORD(?!\{)
				#perl -i -p -e "s/(?<!(ls\{|pl\{|rt\{|[a-z]{3}))$short(?!\{)/\\\acrshort{$key}\\\textsubscript{A}/g" $f
				perl -i -p -e "s/(?<=\s)$short(?=(\s|\.|\:))/\\\acrshort{$key}\\\textsubscript{A}/g" $f
				#perl -i -p -e "s/(?<!(ls|pl|rt|[a-z]{2})\{)$short(?!{)/\\\acrshort{$key}\\\textsubscript{A}/gi" $f
				echo "found in $f"
				#cat $f | perl -p -e "s/(?<!acrshort{)$short(?!{)/\\\acrshort{$key}/g"
			done
		else
			echo "Wrong type or not specified. STOPPING HERE!"
			exit 1
		fi
	done

	if [ `git status | grep -c "working tree clean"` -eq 0 ]
	then
		docName=`ls *.tex | grep -v glossario`
		pdflatex -file-line-error -halt-on-error $docName
		if [ $? -eq 1 ]
		then 
			echo "latex compilation went wrong. exiting"
			exit 1
		fi
		makeglossaries `basename -s .tex $docName`
		pdflatex -file-line-error -halt-on-error $docName
		if [ $? -eq 1 ]
		then 
			echo "********** latex compilation went wrong. exiting **********"
			exit 1
		fi
	fi

	#get back for the next doc, if any
	cd -
done

