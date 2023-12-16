#!/usr/bin/env bash

rm -f DEBUG STDERR /tmp/OUTPUT output.txt raw_output.txt
echo "np" > RESULT 
[ -d obj ] && rm -f obj/*
testcase=$1
if [[ -z "$testcase" ]]; then
    testcase=1
fi
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
        if cat ${output_fn} | tr -d " " | grep ${grep_opts} "${line// /}" >> /dev/null 2>&1 ; then
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
    log_pos "PASSED, found all expected output"

    return 0 ## BASH is fun, this is True
}

# shows the input and output from the target program 
function showOutput() {

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
}

function compile(){

    rm -f a.out mud.bin main.bin /tmp/main.bin /tmp/mud.bin /tmp/a.out
    
    foundcpp=false
    if [[ -f Makefile ]]; then 
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



