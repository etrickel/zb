# testcase must be set 


function checkLastOfSentence(){
    local concount=3
    local check_vowel=0
    while (( "$#" )); do
        arg="$1"        
        if [[ $arg == "-concount" ]]; then
            shift 
            concount=$1
        fi
        if [[ $arg == "-vowel" ]]; then
          check_vowel=1
        fi 
        # Other processing can be added here

        shift  # Shift off the processed argument
    done
    
    last_word=$(tail -n 1 "/tmp/INPUT" | awk '{print $NF}')
    last_word_first_three_chars=$(tail -n 1 "/tmp/INPUT" | awk '{print $NF}'|head -c 3 )
    last_char_of_sentence=$(tail -c 1 "/tmp/INPUT")
    echo "$concount"

    if (( check_vowel == 1 )); then 
        if [[ ! $last_word_first_three_chars =~ ^[aeiouAEIOU]{1}.*$ ]]; then
            echo "Test fails because the last word '$last_word' did not start with a vowel" >> DEBUG 
            echo "vvvvvvvv INPUT vvvvvvvv" >> DEBUG 
            cat /tmp/INPUT >> DEBUG 
            echo "np" > RESULT 
            exit 23
        fi 
    elif [[ ! $last_word_first_three_chars =~ ^[bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ]{$concount}.*$ ]]; then
        echo "Test fails because the last word '$last_word' did not start with $concount consonants" >> DEBUG 
        echo "vvvvvvvv INPUT vvvvvvvv" >> DEBUG 
        cat /tmp/INPUT >> DEBUG 
        echo "np" > RESULT 
        exit 23
    fi

    if [[ ! $last_char_of_sentence =~ ^[.,!?]$ ]]; then
        echo "Test fails because the sentence did not end with a punctuation mark." >> DEBUG 
        echo "vvvvvvvv INPUT vvvvvvvv" >> DEBUG 
        cat /tmp/INPUT >> DEBUG 
        echo "np" > RESULT 
        exit 23
    fi 
    
}


function checkFirstWord(){
    local concount=3
    local check_vowel=0
    while (( "$#" )); do
        arg="$1"        
        if [[ $arg == "-concount" ]]; then
            shift 
            concount=$1
        fi
        if [[ $arg == "-vowel" ]]; then
          check_vowel=1
        fi 
        # Other processing can be added here

        shift  # Shift off the processed argument
    done

    first_word=$(head -n 1 "/tmp/INPUT" | awk '{print $1}')
    first_word_first_three_chars=$(head -c 3 "/tmp/INPUT")
    
   if (( check_vowel == 1 )); then 
        if [[ ! $first_word_first_three_chars =~ ^[aeiouAEIOU]{1}.*$ ]]; then
            echo "Test fails because the firsrt word '$first_word' did not start with a vowel" >> DEBUG 
            echo "vvvvvvvv INPUT vvvvvvvv" >> DEBUG 
            cat /tmp/INPUT >> DEBUG 
            echo "np" > RESULT 
            exit 34
        fi 
    elif [[ ! $first_word_first_three_chars =~ ^[bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ]{$concount}.*$ ]]; then
        echo "Test fails because the first word '$first_word' did not start with $concount consonants" >> DEBUG 
        echo "vvvvvvvv INPUT vvvvvvvv" >> DEBUG 
        cat /tmp/INPUT >> DEBUG 
        echo "np" > RESULT 
        exit 33
    fi
    
}


