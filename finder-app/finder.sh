#!/bin/bash

#Accepts the following runtime arguments: the first argument is a path to a directory on the filesystem, referred to below as filesdir; the second argument is a text string which will be searched within these files, referred to below as searchstr

#Exits with return value 1 error and print statements if any of the parameters above were not specified

#Exits with return value 1 error and print statements if filesdir does not represent a directory on the filesystem

#Prints a message "The number of files are X and the number of matching lines are Y" where X is the number of files in the directory and all subdirectories and Y is the number of matching lines found in respective files, where a matching line refers to a line which contains searchstr (and may also contain additional content).

#check if there are two arguments. if not, print an error. Exit 1
if [ $# -ne 2 ]; then
	echo "Error: need two arguements" >&2
	exit 1
fi

#Define two arguments
filesdir=$1
searchstr=$2

#Check if it represents a directory. if not print an error. Exit 1
if [ ! -d "$filesdir" ]; then
	echo "Error: '$filesdir' is not a valid directory" >&2
	exit 1
fi

#Count the number of files in filesdir and under
number_of_files=$(find "$filesdir" -type f | wc -l)

#Count the matching lines
#Do not count binary files
#throw away errors
#matching_lines=$(grep -r --binary-files=without-match --fixed-strings "$searchstr" 2>/dev/null | wc -l)
matching_lines=$(grep -r  "$searchstr" "$filesdir" 2>/dev/null | wc -l)
#Print the result
echo "The number of files are $number_of_files and the number of matching lines are $matching_lines"
