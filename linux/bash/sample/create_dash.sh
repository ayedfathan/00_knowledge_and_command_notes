#!/bin/bash

function usage_exit()
{
    script_name="$(basename "$0")"
    printf 'Usage : %s [-c CHAR] [-l LENGTH]\n' "$script_name"
    printf 'Examples :\n'
    printf '    %s\n' "$script_name"
    printf '    %s -c _ -l 100\n' "$script_name"
    printf '    %s -c_ -l60\n' "$script_name"
    printf 'Default Value for -c is _ and -l is 72\n'
    printf 'ATTENTION : -c can only have 1 character and -l maximum only 256\n'
    printf '            Character allowed for -c are - _ = +\n'
    exit 2
} >&2

function initialize_char_and_length()
{
    # Initializing char to be appended as underscore(_) and max length to 72
    local l_char='_'
    local l_len=72
    printf '%s|%d\n' "${l_char}" "${l_len}"
}

function process_param()
{
    # Retrive the initial char and length from the main program
    local l_char="${1}"; shift
    local l_len="${1}"; shift

    # Start parsing the parameter given by user in the command line
    while (( $# > 0))
    do
	if grep -q -e '^-c.*' <<< "${1}"; then    
        #if [[ "${1:0:2}" = '-c' ]]; then
	# Found -c passed by user in command line as parameter
	    if [[ "${#1}" -eq 2 ]]; then
	    # The character expected by user is not attached to -c, like -c -
	    # so you need to shift the S1 to get the character expected by user
	        shift 
		l_char="${1}"
            else
            # The character expected by user is attached to -c, like -c-
	    # You need to chop the -c from S1 to get the character expected
	        l_char="${1#-c}"
            fi		    
	    # Make sure the character passed by user in command line not more than 1 char, otherwise exit with error
	    # Character allowed is only _, -, = 
	    [[ "${#l_char}" -eq 1 && "${l_char}" =~ [-_=+] ]] || usage_exit
        elif grep -q -e '^-l[0-9]*$' <<< "${1}" ; then    
        #elif [[ "${1:0:2}" = '-l' ]]; then
	# Found -l passed by user in command line as parameter
	    if [[ "${#1}" -eq 2 ]]; then
	    # The length of character expected by user is not attached to -l, like -l 50
	    # so you need to shift the S1 to get the lenth of character expected by user
	        shift 
		l_len="${1}"
            else
            # The length of character expected by user is attached to -l, like -l50
	    # You need to chop the -l from S1 to get the length of character expected
	        l_len="${1#-l}"
            fi		    
	    # Make sure the length of character passed by user in command line is digit and not more then 256 chars
	    grep -q -e '^[0-9][0-9]*$' <<< "${l_len}" || usage_exit
	    [[ "${l_len}" -le 256 ]] || usage_exit
	else
	# Options passed by user in the command line not being recognized
            usage_exit
	fi
	# Process the next parameter in the command line
	shift 
    done

    # Send to output the final character and length expected by user from the command line
    printf '%s|%d\n' "${l_char}" "${l_len}"
}

function build_the_string()
{
# Receive the length and the characted expected and the print it to output
    output=''
    local l_char="${1}"
    local l_len="${2}"

    for ((i=0 ; i < l_len ; i++))
    do
        output="${output}${l_char}"
    done
    printf '%s\n' "${output}"
}

##################################### MAIN PROGRAM ################################################
IFS='|' read -r param_char param_len <<< "$(initialize_char_and_length)"
IFS='|' read -r param_char param_len <<< "$(process_param "${param_char}" "${param_len}" "${@}")"
build_the_string "${param_char}" "${param_len}"


