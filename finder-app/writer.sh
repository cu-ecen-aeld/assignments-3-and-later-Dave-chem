#!/bin/bash
#Write a shell script finder-app/writer.sh as described below

#Accepts the following arguments: the first argument is a full path to a file (including filename) on the filesystem, referred to below as writefile; the second argument is a text string which will be written within this file, referred to below as writestr

#Exits with value 1 error and print statements if any of the arguments above were not specified

#Creates a new file with name and path writefile with content writestr, overwriting any existing file and creating the path if it doesn’t exist. Exits with value 1 and error print statement if the file could not be created.

#Verify that there are two arguements. if not, print error
if [ $# -ne 2 ]; then
	echo "Error: Two arguments are needed" >&2
	exit 1
fi

#Define varibles aka two arguments
writefile=$1
writestr=$2

#Extract the directory from user input
directory=$(dirname "$writefile")

#Create the directory and parent d if it does not exist. Print error if not successful
if ! mkdir -p "$directory"; then
	echo "Error: directory $directory is not created successfully" >&2
	exit 1
fi

#Write the string into the file. print error if not successful
if ! echo "$writestr" > "$writefile"; then
	echo "Error: Could not write to file $writefile" >&2
	exit 1
 fi
 
 #Status update
 echo "Successfully wrote into $writefile with content:"
 cat "$writefile" 
 
 exit 0
