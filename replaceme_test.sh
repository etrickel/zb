
if [[ -f test1.sh ]]; then 
    if grep -q "REPLACE_ME" test?.sh; then 
        echo "The tests must have the REPLACE_ME removed from everywhere even comments if it somehow got into the comments"
        echo "np" > RESULT
        exit 1
    fi 
fi 
if [[ -f test1.c ]]; then 
    if grep -q "REPLACE_ME" test.c; then 
        echo "The file test.c must have the REPLACE_ME removed from everywhere even comments if it somehow got into the comments"
        echo "np" > RESULT
        exit 1
    fi 
fi 

echo "Test Cases Pass REPLACE_ME test."    
echo "p" > RESULT