
rm -f RESULT DEBUG /tmp/PASSEDOUT /tmp/PASSEDOUT main.bin /tmp/gcovout

if [ -z "$testcase" ]; then
    printf "\033[38;5;9mUSING DEFAULT VALUE FOR TESTCASE of 1\033[0m\n" >> DEBUG 
    testcase=1
fi 

# Function to be called upon exit
function on_exit() {
    echo "---------- Test Output ----------" >> DEBUG 
    [ -f /tmp/PASSEDOUT ] && cat /tmp/PASSEDOUT >> DEBUG 
    [ -f /tmp/FAILEDOUT ] && cat /tmp/FAILEDOUT >> DEBUG 
    
    if [[ -f "/usercode/coding_rooms_unit_tests.sh" ]]; then
      echo "DONE" >> DEBUG
    else
      cat DEBUG RESULT
    fi
}

# Trap the exit signal to call on_exit function
trap on_exit EXIT

echo "Testing code coverage" >> DEBUG 

CFLAGS="" bash test${testcase}.sh > /tmp/PASSEDOUT

gcov "${testFileName}" > /tmp/gcovout 2>&1

retcode=$?

if (( retcode != 0 )); then
    echo "gcov failed run successfully, it returned $retcode" >> DEBUG 
    echo "------ output from gcov was ------ "  >> DEBUG 
    cat /tmp/gcovout >> DEBUG 
    echo "np"
    exit 1
fi 

percentCC=$(cat /tmp/gcovout | grep -i "Lines executed" | head -1 |cut -d":" -f2 | cut -d "." -f1)

if (( percentCC == 100 )); then
    echo "PASSED. 100% code coverage found."
    echo "p" > RESULT
else
    echo "Failed to pass, did not achive 100% code coverage, instead only reached $percentCC%" >> DEBUG 
    echo "np" > RESULT 
fi 


