#!/bin/bash
TEMP_DIR=out/
PASSPHRASE="Iloveprogramming"
OFFSET=33

function run_procedure {
	decrypt_files $1
	check_sums
	unzip_files
	join_files
	clean
}

function print_usage {
	echo "Usage:"
	echo -e "\t" $0 " <passphrase>" 
}

function clean {
	echo "Cleaning temporary directory..."
	if [ -d $TEMP_DIR ]; then
		rm -r $TEMP_DIR
	fi
	echo -e "\t Done."
}

function join_files {
	echo "Joining files..."
	rm decrypted.txt
	cat out/* >> decrypted.txt
	echo -e "\t Done."
}

function unzip_files {
	echo "Unzipping files..."
	for file in $TEMP_DIR*.unwrapped
	do
		unzip -q $file ${file%%.*}
		rm $file
	done
	echo -e "\t Done."
}

function check_sums {
	echo "Checking checksums..."
	for file in $TEMP_DIR*.dec
	do
		UNWRAPPED=${file%%.*}.unwrapped
		FILESIZE=$(stat -f '%z' $file)
		ORIGINAL_FILESIZE=$(expr $FILESIZE - $OFFSET)
		MD5SUM_APPENDED=$(tail -c $OFFSET $file)
		dd bs=1 seek=0 count=$ORIGINAL_FILESIZE if=$file of=$UNWRAPPED &> /dev/null
		MD5SUM_ORIGINAL=$(md5 -q $UNWRAPPED)
		if [ ! "$MD5SUM_ORIGINAL" == "$MD5SUM_APPENDED" ]; then
			echo "Checksum in file " $file " is not correct."
			echo "Exitting..."
			exit
		fi
		rm $file
	done
	echo -e "\t Done."
}

function decrypt_files {
	echo "Decrypting files..."
	for file in $TEMP_DIR/*.gpg
	do
		DECRYPTED=${file%%.*}.dec
		gpg -dq --passphrase $1 --cipher-algo AES256 $file > $DECRYPTED
		if [ $? -ne 0 ]; then
			echo -e "\t Error while decrypting..."
			echo -e "\t Exitting..."
			exit
		fi
		rm $file
	done
	echo -e "\t Done."
}

if [[ "$#" -eq 0 ]]; then
   echo "No arguments supplied."
   echo "Default passphrase is $PASSPHRASE"
   run_procedure $PASSPHRASE
   exit
elif [[ "$#" -eq 1 ]]; then
	echo "Correct number of arguments, attempting decryption."
	run_procedure $1
	echo -e "Dencryption finished successfully."
	exit
else
	echo "Incorrect number of arguments."
	print_usage
	exit
fi

