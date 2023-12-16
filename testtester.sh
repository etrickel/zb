
if [ -n "$1" ]; then 
    testcase=$1
fi

if [ -n "$2" ]; then 
    testPositive=$2 
fi 
if [ -z "$testcase" ]; then
    printf "\033[38;5;9mUSING DEFAULT VALUE FOR TESTCASE of 1\033[0m\n" >> DEBUG 
    testcase=1
fi 

if [ -z "$testPositive" ]; then
    printf "\033[38;5;9mUSING DEFAULT VALUE FOR TESTPOSITIVE of true\033[0m\n" >> DEBUG 
    testPositive="true"
fi 

rm -f RESULT DEBUG /tmp/PASSEDOUT /tmp/PASSEDOUT main.bin
[ -f modelMain.c ] && cp modelMain.c main.c
[ -f model/main.c ] && cp model/main.c main.c

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

echo "Testing #${testcase} testing Working = ${testPositive}" >> DEBUG 

if grep -q "REPLACE_ME" test?.sh; then 
    echo "The test1.sh and test2.sh must have the REPLACE_ME removed from everywhere even comments if it somehow got into the comments" >> DEBUG 
    echo "np" > RESULT
    exit 1
fi 


if [[ "${testPositive,,}" == "true" ]]; then 
    echo "testing positive test" 
    CFLAGS="" bash test${testcase}.sh > /tmp/PASSEDOUT

    if grep -i -q -E "(Pass.*Test|Test.*Pass)" /tmp/PASSEDOUT ; then
        echo 'p' > RESULT
        printf "\033[38;5;10mPASSED b/c test passed for working model version\033[0m\n" >> DEBUG
    else
        printf "\033[38;5;1mFAILED test of test${testcase}.sh, the test script should have passed this program with 'Passed Test'\033[0m\n" >> DEBUG 
        echo "np" > RESULT
        exit 1
    fi 

else # test failing program to fail test case

    CFLAGS="-DBROKEN_VERSION_${testcase}" bash test${testcase}.sh > /tmp/FAILEDOUT
    
    if grep -i -q -E "(Fail.*Test|Test.*Fail)" /tmp/FAILEDOUT ; then
        echo 'p' > RESULT
        printf "\033[38;5;10mPASSED b/c test failed for broken test\033[0m\n"  >> DEBUG
    else
        printf "\033[38;5;1mFAILED test of test${testcase}.sh, the test script should have failed this program with 'Failed Test'\033[0m\n"  >> DEBUG         
        echo "np" > RESULT
        exit 1
    fi 

fi 
