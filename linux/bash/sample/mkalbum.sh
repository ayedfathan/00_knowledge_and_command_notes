#!/bin/bash
# A script to create an album from image file, the album will be html file
# It receive directory as an input and then scan through that directory for image file

# error_exit will receive error message as its input parameter
# echo the error message to user and then exit with error

function error_exit()
{
    printf 'ERROR - %s\n' "${@}"
    exit 1
} >&2

function usage_exit()
{
    printf 'Usage : %s <Directory Name>\n' "$(basename $0)"
    exit 1 
} >&2

# validate_dir will receive dir name as its input parameter
# And make the directory is exists, readable and also writeable
function validate_dir()
{
  local album_dir="${1}"
  [[ -d "${album_dir}" && -w "${album_dir}" ]] || error_exit "Make sure directory ${album_dir} is exists and writable"
}

# Parse_arg will receive argument from user as its input parameter
# And will return the album directory name
function parse_arg()
{
    [[ "${#}" -eq 1 ]] || usage_exit
    local album_dir="${1}"
    printf '%s\n' "${album_dir%/}" # Removing / if exists in the end of the directory name
}

# gen_array_of_image will receive list of file name
# it will check one by one, and only store file with image type
# non image file will be ignored
function gen_array_of_image()
{
    local album_dir="${1}"
    local files="$(ls -1 "${album_dir}")" #Generate the list of files inside album_dir directory

    # For each of the file
    # we are going to check which one is image file
    # anything besides image file will not be included in the image array
    while read -r v_file 
    do
	# check the type of the file whether it is image file or not
	# if file is image type, then add the file name into the array of image
        file "${album_dir}/${v_file}" | grep -qi -e 'image data' && array_of_image+=("${v_file}")
    done <<< "${files}"
}

# Create the html page per image
function create_html_page()
{
    local album_dir="${1}"
    local current="${2}"
    local first=""
    local previous=""
    local next=""
    local last=""

    # Creating the link for first, previous, next and last
    [[ "${3}" = 'EMPTY' ]] && first='<TD> First </TD>' || first='<TD> <A HREF="'"${3%.*}.html"'"> First </A> </TD>'
    [[ "${4}" = 'EMPTY' ]] && previous='<TD> Previous </TD>' || previous='<TD> <A HREF="'"${4%.*}.html"'"> Previous </A> </TD>'
    [[ "${5}" = 'EMPTY' ]] && next='<TD> Next </TD>' || next='<TD> <A HREF="'"${5%.*}.html"'"> Next </A> </TD>' 
    [[ "${6}" = 'EMPTY' ]] && last='<TD> Last </TD>' || last='<TD> <A HREF="'"${6%.*}.html"'"> Last </A> </TD>'

# Create the html file
cat << EOF > "${album_dir}/${current%.*}.html"
<HTML>
<HEAD><TITLE>${current}</TITLE></HEAD>
<BODY>
  <H2>${current}</H2>
<TABLE WIDTH="25%">
  <TR>
  ${first}
  ${previous}
  ${next}
  ${last}
  </TR>
</TABLE>
  <IMG SRC="$current" alt="$current"
   BORDER="1" VSPACE="4" HSPACE="4"
   WIDTH="800" HEIGHT="600"/>
</BODY>
</HTML>
EOF

    printf 'File %s created.\n' "${album_dir}/${current%.*}.html"
}

# gen_html_file will receive album_dir and array of image as input parameter
function gen_html_file()
{
    local album_dir="${1}"
    local last_index="$(( "${#array_of_image[@]}" - 1 ))"
    local current=""
    local first=""
    local previous=""
    local next=""
    local last=""

    # For each member of the array of image
    for (( i=0 ; i < "${#array_of_image[@]}" ; i++))
    do
	current="${array_of_image["${i}"]}"
	# if index is 0, then first empty otherwise set first to image in first index
	[[ "${i}" -eq 0 ]] && first="EMPTY" || first="${array_of_image[0]}"
	# if index is o, then previous also set to empty, otherwise set to image in previous index
	[[ "${i}" -eq 0 ]] && previous="EMPTY" || previous="${array_of_image[(( "${i}" - 1 ))]}"
	# if index is last index, then next and last is empty
	# otherwise set next to next image in the index and last to image in the last index
	[[ "${i}" -eq "${last_index}" ]] && next="EMPTY" || next="${array_of_image[(( "${i}" + 1 ))]}"
	[[ "${i}" -eq "${last_index}" ]] && last="EMPTY" || last="${array_of_image["${last_index}"]}"
	
	# Create the html file for each image file in the index
	create_html_page "${album_dir}" "${current}" "${first}" "${previous}" "${next}" "${last}"
	# if it is the first index than also create index.html from the first html
	[[ "${i}" -eq 0 ]] && cp -- "${album_dir}/${current%.*}.html" "${album_dir}/index.html"
	[[ "${i}" -eq 0 ]] && printf 'File %s created.\n' "${album_dir}/index.html"
    done
}

########################################## MAIN PROGRAM ####################################
read -r album_dir <<< "$(parse_arg "${@}")" # Retrieve album_dir from command argument
validate_dir "${album_dir}" # Make sure that album_dir is directory and also writeable

array_of_image=() # Initialize empty array
gen_array_of_image "${album_dir}" # Generate array of image
# If array_of_image has no members, print error and exit
[[ "${#array_of_image[@]}" -ne 0 ]] || error_exit "There is no image file in folder "${album_dir}""

# Generate the html files
gen_html_file "${album_dir}" 
