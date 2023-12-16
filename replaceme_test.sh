if grep -q "REPLACE_ME" test?.sh; then 
    echo "The test1.sh and test2.sh must have the REPLACE_ME removed from everywhere even comments if it somehow got into the comments"
    echo "np" > RESULT
    exit 1
else
    echo "Test Cases Pass REPLACE_ME test."    
    echo "p" > RESULT
fi 