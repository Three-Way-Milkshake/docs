#!/bin/bash

cd `dirname $0`

git clone https://github.com/Three-Way-Milkshake/docs.wiki.git wiki
cd wiki
mapfile -t acr < <(more Glossario.md | grep "Glossario dei Termini" -B9999 | grep -E "\*\*.+\*\*" -o | cut -f3 -d '*' ) #save acronyms in acr array
mapfile -t glo < <(more Glossario.md | grep "Glossario dei Termini" -A9999 | grep -E "\*\*.+\*\*" -o | cut -f3 -d '*' ) #save glossaries terms in glo array
cd ..
rm -rf wiki

#install extra latex packages
if [ $# -gt 0 ]
then
	if [ $1 == "--install-custom" ]
	then
		sudo cp -rv extra_latex_packages/pgfplots /usr/share/texlive/texmf-dist/tex/latex
		sudo cp -rv extra_latex_packages/pgf-pie /usr/share/texlive/texmf-dist/tex/latex
		sudo mktexlsr
	fi
fi

cd ../../

for doc in `find . -name glossario.txt`
do 
	#go to the root of the doc
	cd `dirname $doc` 
	
	#iterate through acronyms
	for i in `seq 0 $((${#acr[@]}-1))`
	do
		a=${acr[$i]}
		echo "looking for $a"
		
		for f in `grep -ril "$a" | grep '\.tex' | grep -v glossario`
		do
			perl -i -p -e "s/(?<=\s)$a(?=\s|\.|\:|,|'|;)/$a\\\textsubscript{A}/g" $f
			echo "found in $f"
		done
	done
	
	#iterate through terms
	for i in `seq 0 $((${#glo[@]}-1))`
	do
		g=${glo[$i]}
		echo "looking for $g"
		
		for f in `grep -ril "$g" | grep '\.tex' | grep -v glossario`
		do
			perl -i -p -e "s/(?<=\s)$g(?=\s|\.|\:|,|'|;)/$g\\\textsubscript{G}/g" $f
			echo "found in $f"
		done
	done
	
	
	docName=`ls *.tex | grep -v glossario`
	pdflatex -file-line-error -halt-on-error $docName
	if [ $? -eq 1 ]
	then 
	     echo "********** latex compilation went wrong. exiting **********"
	     exit 1
	fi
	pdflatex -file-line-error -halt-on-error --interaction=nonstopmode --interaction=batchmode $docName
	if [ $? -eq 1 ]
	then 
	     echo "********** latex compilation went wrong. exiting **********"
	     exit 1
	fi

	#get back for the next doc, if any
	cd -
done


