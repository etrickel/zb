
function verifyAllTestFiles() {
    local fileStart=$1
    local fileCount=$2
    if (( $(ls test?.sh 2> /dev/null |wc -l) < $fileCount )); then
        printf "Failing test because your instance is missing test scripts from the template, please make sure that all test files are included in your workspace\n" >> DEBUG
        echo "np"
        exit 33
    fi 

    for (( x=$fileStart; x <= $fileCount; x++ )); do 
        if grep -q "REPLACE_ME" test${x}.sh; then 
            echo "The tests must have the REPLACE_ME removed from everywhere even comments if it somehow got into the comments" >> DEBUG
            echo "Found REPLACE_ME in test${x}.sh please create your test case " >> DEBUG
            echo "np" > RESULT
            exit 1
        fi         
    done 

    echo "Test Cases Pass REPLACE_ME test."    
    echo "p" > RESULT
}

if [[ -f test1.sh ]]; then 
    if grep -q "REPLACE_ME" test?.sh; then 
        echo "The tests must have the REPLACE_ME removed from everywhere even comments if it somehow got into the comments" >> DEBUG
        echo "np" > RESULT
        exit 1
    fi 
fi 
if [[ -f test.c ]]; then 
    if grep -q "REPLACE_ME" test.c; then 
        echo "The file test.c must have the REPLACE_ME removed from everywhere even comments if it somehow got into the comments" >> DEBUG
        echo "np" > RESULT
        exit 1
    fi 
fi 

if [[ -f test.cpp ]]; then 
    if grep -q "REPLACE_ME" test.cpp; then 
        echo "The file test.cpp must have the REPLACE_ME removed from everywhere even comments if it somehow got into the comments" >> DEBUG
        echo "np" > RESULT
        exit 1
    fi 
fi 

echo "Test Cases Pass REPLACE_ME test."    
echo "p" > RESULT