#!/usr/bin/env bash
# Printing out the employee data based on State name
# The list of emps information will be group by state full name

######### BEGINNING OF CODES FOR SECURITY PURPOSES ########################
# Secure PATH is being used
\export PATH='/usr/local/bin:/usr/bin:/bin'

# Clear out all aliases
\unalias -a

# Clear the command path hash
hash -r

# Set the hard limit to 0 to turn off core dumps
ulimit -H -c 0 --

# Set a sane/secure IFS (note this is bash & ksh93 syntax only--not portable!)
IFS=$' \t\n'

# Set a sane/secure umask variable and use it
# Note this does not affect files already redirected on the command line
# 022 results in 0755 perms, 077 results in 0700 perms, etc.
UMASK=022
umask $UMASK

# Cleaning up temporary files and folder when exit
function cleanup()
{
    if [[ -n "${temp_dir}" && -n "${file_input}" ]]; then
        rm -f ""${temp_dir}"/"${file_input}".cleaned"
	rm -f ""${temp_dir}"/"${file_input}".sorted"
	rm -f ""${temp_dir}"/"${file_input}".result"
        rmdir "${temp_dir}"
    fi
}
trap 'cleanup' ABRT EXIT HUP INT QUIT

########## END OF CODES FOR SECURITY PURPOSES #############################

# Print out the script usage and exit
function usage_exit()
{
    printf 'Usage : %s FILE_NAME\n' "$(basename "${0}")"
    exit 1
} >&2

# Print error message and then exit the script
function notif_error()
{
    printf 'ERROR - %s\n' "${@}"
    exit 1
} >&2

# Parsing arguments given by user, it only need 1 argument, which is input file name
function parse_args()
{
    [[ "$#" -eq 1 ]] && file_input="${1}" || usage_exit
    
}

# Make sure the input file is exists and readable 
function validate_input_file()
{
    [[ -f "${file_input}" && -r "${file_input}" ]] || notif_error "Make sure input file '"${file_input}"' exists and readable"
}

# Creating temporary directory
function create_temp_dir()
{
   temp_dir="$(mktemp -d)" || notif_error "Not able to create temporary directory"
}

# Sanitize input file from unexpected condition below
# Leading and trailing space, empty line, space between field separator, multiple space
# and then changing the State name from abbreviation into full state name
function cleanup_input_file()
{
   sed -e '
            # Clean up blank line
	    /^[[:space:]]*$/d

   	    # Clean up the leading space from the line
	    s/^[[:space:]]*//

	    # Clean up the trailing space from the line
	    s/[[:space:]]*$//

	    # Clean up the space between field separator(,)
	    s/[[:space:]]*,[[:space:]]*/,/g

	    # Change the state abbreviation into full name of the state
	    s/ MA/,Massachusetts/
	    s/ VA/,Virginia/
	    s/ OK/,Oklahoma/
	    s/ PA/,Pensylvania/
	    s/ CA/,California/

          ' "${file_input}" > ""${temp_dir}"/"${file_input}".cleaned"
}

# Sort the already sanitized input file based on field 4, which is the state name
function sort_input_file()
{
    sort -t, -k4,4 ""${temp_dir}"/"${file_input}".cleaned" > ""${temp_dir}"/"${file_input}".sorted"
}

# print out the data group by state name
function print_by_state()
{
    local state=''
    local err_msg=''
    cat /dev/null > ""${temp_dir}"/"${file_input}".result"

    while IFS=',' read -r -a line; do
        # If number of field not equal to 4, then exit.
	[[ "${#line[@]}" -eq 4 ]] || { err_msg="This line '"${line[@]}"' has more than 4 fields"; 
	                               notif_error "${err_msg}"; 
			             }
	if [[ "${state}" != "${line[3]}" ]]; then
	    [[ "${state}" != '' ]] && printf '\n' >> ""${temp_dir}"/"${file_input}".result"
	    state="${line[3]}"
	    printf '%s\n' "${state}" >> ""${temp_dir}"/"${file_input}".result" 
	    printf '\t%s, %s, %s\n' "${line[0]}" "${line[1]}" "${line[2]}" >> ""${temp_dir}"/"${file_input}".result"
	else
	    printf '\t%s, %s, %s\n' "${line[0]}" "${line[1]}" "${line[2]}" >> ""${temp_dir}"/"${file_input}".result"
	fi
    done < ""${temp_dir}"/"${file_input}".sorted"

    cat ""${temp_dir}"/"${file_input}".result"
}

########################## MAIN PROGRAM ############################################

# Intializing the global variable
file_input=''
temp_dir=''

# input file expected for this script is file list
parse_args "${@}"
validate_input_file 
create_temp_dir
cleanup_input_file
sort_input_file
print_by_state
