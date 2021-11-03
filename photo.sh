#!/bin/bash

function createHieararchy(){	
	exiftool  -d "$1"/%Y/%Y_%m_%d  "-directory<filemodifydate" "-directory<datetimeoriginal"  "-directory<createdate" .
	cd "$1"
}
function name_images(){
	#$1 is the name of directory where images needed to be renamed
	for photo in $(find $1 -name '*png')
	do
	if [[ $photo != *-* ]] 
	then
	previousName=$photo
	path=${photo%/*}/
	parentname="$(basename "$(dirname "$photo")")"
	newName="$path$parentname-$(basename $photo)"
	mv ${photo} ${newName}
	fi
	done
}
function startHtmlFile(){
	touch index.html
	echo '<!DOCTYPE html>
	<html>
	<head>
	<title>Page Title</title>
	</head>
	<body>'>$1
}
function endHtmlFile(){
	echo '</body>
	</html>'>>$1
}
function createThumbs(){
for d in $(find . -mindepth 2 -maxdepth 2 -type d)
do
	name=$(basename $d)
	mkdir $d/.thumbs
	for photo in $(find $d -name '*png')
	do
    echo "okk"
    # Stores the width of the current file
    #iwidth=`identify -format "%w" $i`
    #smallWidth=$((iwidth / 2))
  
  
    # Checks current filename does not end with '-thumb' and
    # file is greater than desired width
    if [[ $photo != *-thumb.png ]] 
    then
	   
       
        # Stores filename without extension
        filename=`basename -s .png $photo`
        # Creates thumbnail and adds -thumb to end of new file
        
        convert  ${photo} -resize x150 "$filename-thumb.png"
		mv "$filename-thumb.png" $d/.thumbs
        
    fi
	done
	
done
}
function generate_global_html_file(){
for d in $(find . -mindepth 1 -maxdepth 1 -type d) 
do   

	name=$(basename $d)
	nu=$(ls -lR | grep --count \.png$)
	echo '<a href='"${name}"/index.html'>' "${name} ${nu}" '</a>'>>$1
done
}
function display_thumbnails(){
	for photo in $(find $1 -name '*-thumb.png')
	do    
		dir_name="$(dirname -- $photo)"
		file_name="$(basename -- $photo)"
		h=${file_name%-*}
		echo '<a target="_blank" href="../'"${dir_name}"'/../'"${h}"'.png">'>>$1/index.html	
		echo '<img src="../'"${photo}"'" alt="picture is missing..." />'>>$1/index.html
		echo '</a>'>>$1/index.html
	done
}
function error() {
	echo "(Error)\"$2\": $1" >&2
	exit 2
}
function usage() {
	

	echo "NAME 
		palbum - create a photo album from a set of photos taken by a digital
		camera or a smartphone.

    SYNOPSIS
		palbum <INPUT-DIRECTORY> <OUTPUT-DIRECTORY>

		
	OVERVIEW
		The  palbum  program is a utility that helps you create simple static
        HTML photo albums from the  pictures taken with a digital camera or a
	    smartphone stored in INPUT-DIRECTORY.  The resulting album is created
	    in  OUTPUT-DIRECTORY.  An already existing album  may be complemented
	    with more photographs.
	AUTHOR
		Written by the clever HROUR BOUTHAINA."
}














if [ $# -lt 2 ]
then
	usage
	exit 1
fi


if [ ! -d "$1" ];
then
	error "not a directory" $1
fi
cd $1

createHieararchy "${2}"
for d in $(find . -mindepth 1 -maxdepth 1 -type d)
do
	name_images "$d"
done
createThumbs 
startHtmlFile "index.html"
generate_global_html_file "index.html"
endHtmlFile "index.html"
for d in $(find . -mindepth 1 -maxdepth 1 -type d)
do
	touch $d/index.html
	startHtmlFile $d"/index.html"
	display_thumbnails "$d"
	endHtmlFile $d"/index.html"
done


