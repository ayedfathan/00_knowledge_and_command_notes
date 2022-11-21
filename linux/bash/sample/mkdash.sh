#!/bin/bash
# Print out dash for number of times based on user input

function usage_exit()
{
    printf 'Usage : %s [OPTIONS] LENGTH\n' "$(basename "${0}")"
    printf 'LENGTH less or equal to 150\n'
    printf 'OPTIONS :\n'
    printf ' -l : no new line\n'
    printf ' -s : print space between dash\n'
    exit 1
} >&2

function parse_options()
{
    local options="${1}"
    local option=''

    # If options empty then usage exit, user pass the - but with no options
    [[ -z "${options}" ]] && usage_exit

    # For each of the character in options
    for (( i=0 ; i < "${#options}" ; i++ )) do
        option="${options:${i}:1}"
	if [[ "${option}" = 'l' ]]; then
	    no_new_line=0 # Set no new line to TRUE
	elif [[ "${option}" = 's' ]]; then
	    space_in_char=0 # set space_in_char to TRUE
	else
	    usage_exit
	fi
    done 
}

function parse_args()
{
    # Check number of argument is at least 1
    [[ "${#}" -ge 1 ]] || usage_exit

    # Check the last arguments is digit otherwise exit with usage
    # We want the last argument is for length
    [[ "${@: -1}" =~ ^[0-9]+$ ]] || usage_exit

    # Travel within arguments
    while [[ "${#}" > 0 ]]
    do
	if [[ "${1}" =~ ^[0-9]+$ ]]; then
	# arguments is for length
	    length="${1}"
        elif [[ "${1}" =~ ^- ]]; then
	# Argument is options, whether s or l 
	    parse_options "${1#-}"
	else
	# Argument is unknown
	    usage_exit
	fi

	# go to next argument
	shift
    done

    # Length can't be more than 150 characters
    [[ "${length}" -le 150 ]] || usage_exit
}

function construct_dashes()
{
    # Check whether space_in_char is TRUE
    if [[ "${space_in_char}" -eq 0 ]] ; then 
        char_to_print="${char_to_print} "
    fi

    for (( i=0 ; i < "${length}" ; i++ )) do
        dashes="${dashes}${char_to_print}"
    done
}

############################# MAIN PROGRAM ##########################

# Initialize the variable
char_to_print='-'
length=0
no_new_line=1   # no_new_line equal to FALSE
space_in_char=1 # space_in_char set to FALSE


# Parse all the arguments passed by user
parse_args "${@}"


# Construct the dash based on the length expected
dashes=""
construct_dashes


# Print out the dashes constructed
[[ "${no_new_line}" -eq 0  ]] && printf '%s' "${dashes}" || printf '%s\n' "${dashes}"


