#!/bin/bash

#uses exiftool to create hiearchy in the output directory containing years and ever year contains dates 
#information are extracted from images in the current directory , in the script we move to the symlink 
#to have images , the exiftool bases first on createDate if exists , otherwise on the datetimeoriginal 
#if exists ,otherwise on filemodifydate which always exists 
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
	#creates a .thumbs directory in every directory named before as a  day 
	mkdir $d/.thumbs
	for photo in $(find $d -name '*png')
	do
    # Checks current filename does not end with '-thumb' and
    if [[ $photo != *-thumb.png ]] 
    then
        # Stores filename without extension
        filename=`basename -s .png $photo`
        # Creates thumbnail and adds -thumb to end of new file
        convert  ${photo} -resize x150 "$filename-thumb.png"
		#moves to the corresponding directory
		mv "$filename-thumb.png" $d/.thumbs       
    fi
	done	
done
}
function generate_global_html_file(){
#searching to directories created as years 
for d in $(find . -mindepth 1 -maxdepth 1 -type d) 
do   
	name=$(basename $d)
	#counting how much images in every directory
	number=$(ls -lR | grep --count \.png$)
	#displaying infos as links in the index html file 
	echo '<a href='"${name}"/index.html'>' "${name} ${number}" '</a>'>>$1
done
}
#search every thumbnails created before to write it in the html file 
function display_thumbnails(){
	for photo in $(find $1 -name '*-thumb.png')
	do  
	    #we need the actual image worrespending to thumbnail  
		dir_name="$(dirname -- $photo)"
		file_name="$(basename -- $photo)"
		actual_image=${file_name%-*}
		#to make a link to it 
		echo '<a target="_blank" href="../'"${dir_name}"'/../'"${actual_image}"'.png">'>>$1/index.html	
		echo '<img src="../'"${photo}"'" alt="picture is missing..." />'>>$1/index.html
		echo '</a>'>>$1/index.html
	done
}
#displays errors and quit the program
function error() {
	echo "(Error)\"$2\": $1" >&2
	exit 2
}
#usage function show how to use the script 
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

#handling some error related to arguments of script 
if [ $# -lt 2 ]
then
	usage
	exit 1
fi
if [ ! -d "$1" ];
then
	error "not a directory" $1
fi

#create symlink to the input directory
ln -s $1 dir

#move to this symlink to create our album there
cd dir

#create an hiearchy based on year and day of the year the image was taken ,
#argument is the output directory
createHieararchy "${2}"

#renaming all the images in the hierarchy in format "parentDirectory-originalname"
for d in $(find . -mindepth 1 -maxdepth 1 -type d)
do
	name_images "$d"
done

#create thumbnails based on images in the hieerarchy 
createThumbs 

# writing the global html file which contains years and number of photos taken in this year 
# every year is a link to html file correspending 
startHtmlFile "index.html"
generate_global_html_file "index.html"
endHtmlFile "index.html"

#creating html file for every year in the correspending directory 
#every file displays thumbnails which are links to actual photo
for d in $(find . -mindepth 1 -maxdepth 1 -type d)
do
	touch $d/index.html
	startHtmlFile $d"/index.html"
	display_thumbnails "$d"
	endHtmlFile $d"/index.html"
done
