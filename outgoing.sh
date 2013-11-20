#!/bin/bash
TEMP_DIR=out/
PASSPHRASE="Iloveprogramming"

function run_procedure {
	clean
	split_text $1
	zip_files
	calculate_sums
	encrypt_files	
}

function print_usage {
	echo "Usage:"
	echo -e "\t" $0 " <file_name.txt> <passphrase>" 
}

function clean {
	echo "Cleaning temporary directory..."
	if [ -d $TEMP_DIR ]; then
		rm -r $TEMP_DIR
	fi
	echo -e "\t Done."
}

function split_text {
	echo "Splitting files..."
	if [ ! -d $TEMP_DIR ]; then
		mkdir $TEMP_DIR
	fi
	split -a 10 $1 $TEMP_DIR
	echo -e "\t Done."
}

function zip_files {
	echo "Zipping files..."
	for file in $TEMP_DIR* 
	do
		zip -q $file.zip $file
		rm $file
	done
	echo -e "\t Done."
}

function calculate_sums {
	echo "Calculating checksums..."
	for file in $TEMP_DIR*.zip
	do
		md5 -q $file >> $file
	done
	echo -e "\t Done."
}

function encrypt_files {
	echo "Encrypting files..."
	for file in $TEMP_DIR*.zip
	do
		gpg -c --passphrase $PASSPHRASE --cipher-algo AES256 $file
		mv $file.gpg ${file%%.*}.gpg
		rm $file
	done
	echo -e "\t Done."
}

if [[ "$#" -eq 1 ]]; then
    echo "Default passphrase is $PASSPHRASE"
elif [[ "$#" -eq 2 ]]; then
	PASSPHRASE=$2
else 
    echo "Incorrect number of arguments."
    exit
fi

if [[ $1 =~ \.txt$ ]]; then
	echo "Correct file extension, starting procedure."
	run_procedure $1
	echo -e "Encryption finished successfully."
	exit
else
	echo "Incorrect file extension"
	print_usage
	exit
fi