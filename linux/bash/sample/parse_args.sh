#!/bin/bash

function usage_exit()
{
   printf 'Usage : %s [-l] [-s] [-u USER_NAME] [-p PASSWORD] DATABASE_NAME MACHINE_NAME\n' "$(basename "${0}")"
   exit 1
} >&2

function parse_args()
{
   while getopts 'lsu:p:' OPTION
   do
       case $OPTION in
	   l) l_flag=1
	      ;;
           s) s_flag=1
	      ;;
	   u) u_value="${OPTARG}"
	      ;;
	   p) p_value="${OPTARG}"
	      ;;
	   ?) echo 'wrong options'
              usage_exit
	      ;;
       esac
   done 

   shift $(( "${OPTIND}" - 1 ))
   # Make sure we still had 2 arguments left after shift
   [[ "${#}" -eq 2 ]] || usage_exit
   db_name="${1}"
   machine_name="${2}"
}

############################## MAIN PROGRAM ###########################

# Initializing variable
l_flag=0	 # l_flag set to FALSE
s_flag=0	 # s_flag set to FALSE
u_value=''	 # u_value set to empty string
p_value=''	 # p_value set to empty string
db_name=''	 # db_name set to empty string
machine_name=''  # Machine_name set to empty string

# Parse all the argument passed on by users
parse_args "${@}"

# Print out the value of the arguments
echo "Flag for l : ${l_flag}"
echo "Flag for s : ${s_flag}"
echo "Value for u : ${u_value}"
echo "Value for p : ${p_value}"
echo "Value for database name : ${db_name}"
echo "Value for machine name : ${machine_name}"
