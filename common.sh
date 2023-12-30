#!/usr/bin/env bash

rm -f DEBUG STDERR /tmp/OUTPUT output.txt raw_output.txt /tmp/COMP_EXPECTED /tmp/COMP_STUDENT
echo "np" > RESULT 
[ -d obj ] && rm -f obj/*

if [[ -z "$showdebug" ]]; then 
        showdebug=0
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -d /usercode ]]; then
    cd /usercode || exit 33
fi

###########################################################################################
#    START FUNCTIONS SECTION
###########################################################################################

# Function to be called upon exit
function on_exit() {
    if grep -E "^p" RESULT > /dev/null; then
        echo "Testing Complete successfully, exiting tester." >> DEBUG
    else
        showOutput
        echo "Error occurred, exiting tester ." >> DEBUG
    fi        
    if [[ -f "/usercode/coding_rooms_unit_tests.sh" ]]; then
        echo "DONE" >> DEBUG
    else
            cat DEBUG RESULT
    fi
}

# Trap the exit signal to call on_exit function
trap on_exit EXIT

function standardExec(){
    
    [ -f /tmp/INPUT ] || touch /tmp/INPUT

    ./main.bin "$@" > /tmp/OUTPUT < /tmp/INPUT 2>> DEBUG

    cat /tmp/OUTPUT | tr -d " " > /tmp/SQUISHED_OUTPUT
}

# tests whether the output has the expected values in 
# it automatically removes all spaces when testing but shows missing portion 
# with spaces
# default output location is /tmp/OUTPUT
function testoutputSimple(){
    EXPECTED="$1"
    grep_opts="$2"
    output_fn="/tmp/OUTPUT"
    if [[ -n "$3" ]]; then 
        echo "Setting output_fn to NON STANDARD /tmp/OUTPUT, $3" >> DEBUG
        output_fn=$3
    fi 

    while IFS=" " read -r line; do
        if cat ${output_fn} | tr -d " " | grep -i ${grep_opts} "${line// /}" >> /dev/null 2>&1 ; then
            continue
        else
            if [[ -f /tmp/COMP_EXPECTED ]] && [[ -f /tmp/COMP_STUDENT ]]; then
                icdiff /tmp/COMP_EXPECTED /tmp/COMP_STUDENT
            fi 
            log_neg "\t\033[38;5;3mMISSING '${line}' in output. \033[0m \n"    >> DEBUG
            echo "np" > RESULT 
            exit 109
        fi
    done <<< $EXPECTED
    
    echo "p" > RESULT 
    log_pos "PASSED, found expected output"

    return 0 ## BASH is fun, this is True
}

# tests whether the output has the expected values in 
# it automatically removes all spaces when testing but shows missing portion 
# with spaces
# default output location is /tmp/OUTPUT
function testInputOutputv2(){
    local EXPECTED="$1"
    shift
    local grep_opts=""
    local output_fn="/tmp/OUTPUT"
    local print_expected=0
    local icdiff=0
    while (( "$#" )); do
        arg="$1"
        if [[ $arg == "-grepopts" ]]; then
            shift
            grep_opts="$1"
        fi
        if [[ $arg == "-output" ]]; then
            shift
            echo "Setting output_fn to NON STANDARD /tmp/OUTPUT, $2" >> DEBUG
            output_fn="$1"
        fi
        if [[ $arg == "-print" ]]; then
            print_expected=1  # Set print flag to true (1) if '-print' is found
        fi
        if [[ $arg == "-icdiff" ]]; then
            icdiff=1  # Set print flag to true (1) if '-print' is found
        fi
        # Other processing can be added here

        shift  # Shift off the processed argument
    done
    

    while IFS=" " read -r line; do
        if cat ${output_fn} | tr -d " " | grep -i ${grep_opts} "${line// /}" >> /dev/null 2>&1 ; then
            continue
        else
            if [[ -f /tmp/COMP_EXPECTED ]] && [[ -f /tmp/COMP_STUDENT ]]; then
                icdiff /tmp/COMP_EXPECTED /tmp/COMP_STUDENT
            fi 
            log_neg "\t\033[38;5;3mMISSING '${line}' in output. \033[0m \n"    >> DEBUG
            if [[ $icdiff -eq 1 ]]; then
                if [[ ! -f /tmp/COMP_STUDENT ]]; then 
                    cp /tmp/OUTPUT /tmp/COMP_STUDENT
                fi 
                if [[ ! -f /tmp/COMP_EXPECTED ]] ; then
                    echo $EXPECTED > /tmp/COMP_EXPECTED
                fi     
                icdiff /tmp/COMP_EXPECTED /tmp/COMP_STUDENT >> DEBUG
                
            fi 
            echo "np" > RESULT 
            exit 109
        fi
    done <<< $EXPECTED
    
    echo "p" > RESULT 
    if [[ $print_expected -eq 1 ]];then 
        log_pos "PASSED, in output found '$EXPECTED' "
    else
        log_pos "PASSED, found expected output"
    fi 

    return 0 ## BASH is fun, this is True
}

# shows the input and output from the target program 
function showOutput() {
    # doing this so that error messages and such will be at bottom instead of above output
    mv DEBUG /tmp/TMP_DEBUG
	if [[ -f /tmp/INPUT ]] && (( $(stat -c%s "/tmp/INPUT") > 1 )); then
        
        printf "\033[38;5;13m>>>>>>>>>>>>>>>>>> standard INPUT \033[0m\n" >> DEBUG
	    cat /tmp/INPUT >> DEBUG
        printf "\033[38;5;13m^^^^^^^^^^^^^^^^ END standard input ^^^^^^^^^^^^^^^^\033[0m\n" >> DEBUG
	fi
	if [[ -f /tmp/OUTPUT ]]; then
        printf "\033[38;5;13m<<<<<<<<<<<<<<<<<< standard OUPUT \033[0m\n" >> DEBUG
        cat /tmp/OUTPUT >> DEBUG
        printf "\033[38;5;13m^^^^^^^^^^^^^^^^ END standard output ^^^^^^^^^^^^^^^^\033[0m\n" >> DEBUG
    fi 
    
    cat /tmp/TMP_DEBUG >> DEBUG 
}

function compile(){

    rm -f a.out mud.bin main.bin /tmp/main.bin /tmp/mud.bin /tmp/a.out
    echo "CFLAGS COMPILE =$CFLAGS"
    foundcpp=false
    if [[ -f Makefile ]]; then 
        if [[ -n "$1" ]] && [[ "$1" == "clean" ]]; then 
            make clean 
        fi 
        make    >> DEBUG 2>&1
    else 
        if [[ -f maze.h ]]; then 
            gcc -g -Wall -Werror -o $CFLAGS main.bin main.c maze.h 
        else
            gcc -g -Wall -Werror -o $CFLAGS main.bin main.c 
        fi 
    fi 

    compile_ret=$?

    if [[ $compile_ret -ne 0 ]]; then
            log_neg "\t\033[38;5;3mFAILED to compile \033[0m \n" 
            echo "np" > RESULT
            exit 44
    fi
}

log_pos() {
        msg="$1"
        printf "\033[38;5;10m✔ ️$msg\033[0m\n" >> DEBUG
}
log_neg() {
        msg="$1"
        printf "\n\033[38;5;3m$msg\033[0m\n" >> DEBUG
        echo "np" > RESULT
}


# Function to get the line number of the first occurrence of a substring after a specific line
# Drawback doesn't work too well when subsequent location is substring in prior location.
# had "Alley at Levee" then "Levee"
get_line_number() {
    # CAREFUL DEBUGGING: this function uses print as output so debugging messages sent to standard output will break
    temp_file="/tmp/WIP_FILE"
    
    printf "" > $temp_file 
    # Write the line number for each of the first x lines
    start=$2
    
    for (( i=1; i<=$start; i++ )); do
        echo "$i" >> "$temp_file"
    done
    
    local file=$3

    # Append the rest of the file starting from line x+1
    tail -n +"$((start+1))" "$file" >> "$temp_file"
    
    local ln=$(grep -n -m 1 -E '^.{0,60}'${1} "$temp_file" | cut -d: -f1)
    
    local maxline=$4 

    if (( ln > maxline )); then
        printf "\033[38;5;14mMatch found for '${1}' in output at line $ln, which is too high, which means the match came from a raw print of the json file or there is too much debug code (maxline = $maxline) \n\033[0m" >> DEBUG 

    elif (( ln > start )); then
        printf "Match found for '${1}' in output at line $ln, which is greater than the last line found at ${2}\n" >> DEBUG 
        printf "${ln}"
    else
        printf "Failed finding next match '${1}' in output at line $ln, but need to find after ${2}\n" >> DEBUG 
        printf ""
    fi 
}

# verifies that the text snippets provided as the first argument are encountered in order 
# in the output from the program
function verifyInOrder()
{   
    maxline=500
    if [[ "$1" == "-maxline" ]]; then
        shift
        maxline=$1
        shift 
    fi     

    # The last argument is separately stored
    local file=${@: -1}

    # All arguments except the last one are treated as array elements
    local order=("${@:1:$#-1}")
    local start=0
    
    IFS=","; printf "This test is verifying that following items appear in order: \n\t ${order[*]} \n" >> DEBUG 
    # Loop through each substring
    for str in "${order[@]}"; do
    # Get the line number of the first occurrence of the substring after the starting line
    
        line=$(get_line_number "$str" "$start" "$file" "$maxline" )

        # Check if the substring was found
        if [[ -z "$line" ]]; then
            printf "\033[38;5;1mFAILED to find '${str}' in the proper order \033[0m\n" >> DEBUG 
            printf "Expected order of values are " >> DEBUG 
            IFS=","; printf "${order[*]}\n" > /tmp/junk
            
            grep --color=always -E "${str// /.}|$" /tmp/junk >> DEBUG 
            
            pattern=$(IFS="|"; echo "${order[*]}")
            if (( $(cat /tmp/OUTPUT |wc -c ) > 20000 )); then
                tail -500 /tmp/OUTPUT > /tmp/temp
            else
                grep -E --color=always "$pattern|$" /tmp/OUTPUT > /tmp/temp
            fi 
            
            cp /tmp/temp /tmp/OUTPUT
    
            printf "\n" >> DEBUG 
            exit 1
        else
            # Update the start to the line number for the next search
            start=$line
        fi
    done
}


verifyCount(){
    local expectedStr="$1"
    shift
    local expectedCount=$1
    shift
    local grepopt=""
    if [[ $1 == "-useE" ]]; then 
        grepopt=" -E "
    fi 

    theCount=$(grep -i ${grepopt} "${expectedStr// /}" /tmp/SQUISHED_OUTPUT | wc -l)

    if [[  $theCount -eq $expectedCount ]]; then
        echo "Found $theCount lines that matched the pattern '$expectedStr' in the output " >> DEBUG
    else
        log_neg "Failed Test, looking for the input to produce $expectedCount lines that match the pattern `\033[36mgrep -i $grepopt '$expectedStr'\033[38;5;3m` in program's output; instead found ${theCount} lines meeting the criteria. Check that your program is displaying the correct number of lines for the input. You might also consider removing any debugging code that might be matching the pattern. \033[0m\n"
        exit 1
    fi
}