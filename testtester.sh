
rm -f RESULT DEBUG /tmp/PASSEDOUT /tmp/FAILEDOUT main.bin
if [ -n "$1" ]; then 
    printf "\033[38;5;9mUSING PARAMETER VALUE FOR TESTCASE of 1\033[0m\n" >> DEBUG 
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

if [ -n "$testMyself" ]; then 
    testPositive="true"
    printf "\033[38;5;9mUSING LEARNER'S TESTCASE TO TEST LEARNER'S CODE\033[0m\n" >> DEBUG 
else    
    [ -f modelMain.c ] && cp modelMain.c main.c
    [ -f model/main.c ] && cp model/main.c main.c
fi 

# Function to be called upon exit
function on_exit() {
    echo "########## Test Output ##########" >> DEBUG 
    [ -f /tmp/PASSEDOUT ] && cat /tmp/PASSEDOUT >> DEBUG 
    [ -f /tmp/FAILEDOUT ] && cat /tmp/FAILEDOUT >> DEBUG 
    [ -f /tmp/OUTPUT ] && cat /tmp/OUTPUT >> DEBUG 
        
    if [[ -f "/usercode/coding_rooms_unit_tests.sh" ]]; then
      echo "DONE" >> DEBUG
    else
      cat DEBUG RESULT
    fi
}

# Trap the exit signal to call on_exit function
trap on_exit EXIT

if [[ -n "$testName" ]]; then
    # test unit test in test.c and test.bin
    
    echo "Testing Unit Test #${testcase} Expecting Test to Pass = ${testPositive}" >> DEBUG 
    
    if [[ "$testPositive" == "true" ]]; then
        export CFLAGS=""
        EXPECTED_OUTPUT="Test PASSED.*${testName//test/}"
        EXPECTED_OUTPUT="${EXPECTED_OUTPUT%_*}"
    else
        export CFLAGS="-DBROKEN_VERSION_${testcase}"        
        EXPECTED_OUTPUT="Test Failed.*${testName//test/}"
        EXPECTED_OUTPUT="${EXPECTED_OUTPUT%_*}"
    fi 
    
    make clean 
    
    compile 
    
    ./test.bin ${testName} > /tmp/OUTPUT 2>&1


    testoutputSimple "$EXPECTED_OUTPUT" " -E "

else 
    # test bash script test case created by learner
    
    echo "Testing Base Test #${testcase} Expecting Test to Pass = ${testPositive}" >> DEBUG 

    if grep -q "REPLACE_ME" test?.sh; then 
        echo "The test1.sh and test2.sh must have the REPLACE_ME removed from everywhere even comments if it somehow got into the comments" >> DEBUG 
        echo "np" > RESULT
        exit 1
    fi 

    if [[ "${testCoverage,,}" == "true" ]]; then 
        CFLAGS="" bash test${testcase}.sh > /tmp/PASSEDOUT
        
        gcov ${testCoverageFile}

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
        if [[ -z "$defnumber"]]; then
            defnumber=${testcase}
        fi 
        CFLAGS="-DBROKEN_VERSION_${testcase}" bash test${defnumber}.sh > /tmp/FAILEDOUT
        
        if grep -i -q -E "(Fail.*Test|Test.*Fail)" /tmp/FAILEDOUT ; then
            echo 'p' > RESULT
            printf "\033[38;5;10mPASSED b/c test failed for broken test\033[0m\n"  >> DEBUG
        else
            printf "\033[38;5;1mFAILED test of test${testcase}.sh, the test script should have failed this program with 'Failed Test'\033[0m\n"  >> DEBUG         
            echo "np" > RESULT
            exit 1
        fi 

    fi 
fi 
