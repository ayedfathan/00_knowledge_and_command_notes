#!/bin/bash

### Purposes : A script that will print char -, _, +, =,  up to 256 characters

function usage_exit()
{
# Print out the usage of the script, if user command not as expected

    script_name="$(basename "$0")"
    printf 'Usage : %s [-c CHAR] [-l LENGTH] [-n] \n' "$script_name"
    printf 'Output will have new line if -n put as an option, default no new line.\n'
    printf 'Examples :\n'
    printf '    %s\n' "$script_name"
    printf '    %s -c _ -l 100\n' "$script_name"
    printf '    %s -c_ -l60\n' "$script_name"
    printf 'Default Value for -c is _ and -l is 72.\n'
    printf 'ATTENTION : -c can only have 1 character and -l maximum only 256.\n'
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
# Processing all the option given by user when execute the command

    # Retrive the initial char and length from the main program
    local l_char="${1}"; shift
    local l_len="${1}"; shift
    local l_new_line=1 # new line equal to FALSE

    # Start parsing the parameter given by user in the command line
    while (( $# > 0))
    do
        if [[ "${1}" =~ ^-c[-_=+]?$ ]]; then
	# Found -c passed by user in command line as parameter
	    if [[ "${#1}" -eq 2 ]]; then
	    # The character expected by user is not attached to -c, like -c -
	    # so you need to shift the $1 to get the character expected by user
	        shift 
		l_char="${1}"
            else
            # The character expected by user is attached to -c, like -c-
	    # You need to chop the -c from $1 to get the character expected
	        l_char="${1#-c}"
            fi		    
	    # Make sure the character passed by user in command line not more than 1 char, otherwise exit with error
	    # Character allowed is only _, -, =, and +
	    [[ "${#l_char}" -eq 1 && "${l_char}" =~ [-_=+] ]] || usage_exit
        elif [[ "${1}" =~ ^-l[0-9]*$ ]]; then
	# Found -l passed by user in command line as parameter
	    if [[ "${#1}" -eq 2 ]]; then
	    # The length of character expected by user is not attached to -l, like -l 50
	    # so you need to shift the $1 to get the lenth of character expected by user
	        shift 
		l_len="${1}"
            else
            # The length of character expected by user is attached to -l, like -l50
	    # You need to chop the -l from $1 to get the length of character expected
	        l_len="${1#-l}"
            fi		    
	    # Make sure the length of character passed by user in command line is digit and not more then 256 chars
	    [[ "${l_len}" =~ ^[0-9]+$ ]] || usage_exit
	    [[ "${l_len}" -le 256 ]] || usage_exit
	elif [[ "${1}" =~ ^-n$ ]]; then
	# User want to print with new line
            l_new_line=0 # Set new line to TRUE
	else
	# Options passed by user in the command line not being recognized
            usage_exit
	fi
	# Process the next parameter in the command line
	shift 
    done

    # Send to output the final character and length expected by user from the command line
    printf '%s|%d|%d\n' "${l_char}" "${l_len}" "${l_new_line}"
}

function build_the_string()
{
# Receive the length and the characted expected and the print it to output
    output=''
    local l_char="${1}"
    local l_len="${2}"
    local l_new_line="${3}"

    for ((i=0 ; i < l_len ; i++))
    do
        output="${output}${l_char}"
    done
    [[ "${l_new_line}" -eq 0 ]] && printf '%s\n' "${output}" || printf '%s' "${output}"
}

##################################### MAIN PROGRAM ################################################
IFS='|' read -r param_char param_len <<< "$(initialize_char_and_length)"
param_new_line=1 # Set the new line to FALSE
IFS='|' read -r param_char param_len param_new_line <<< "$(process_param "${param_char}" "${param_len}" "${@}")"
build_the_string "${param_char}" "${param_len}" "${param_new_line}"


