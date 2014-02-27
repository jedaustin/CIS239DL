#!/bin/bash
source ./*_Taylorfunction.sh
#Running until loop with no condition to keep looping the application until the user presses Enter
until [ ]; do
echo "Please type in an English word to have it interpreted to Pig Latin or press Enter to quit:" 
#The read command accepts user input and sets the input as the variable word
read -r word
#If statement exits if length of the word is 0 for the variable ${word}
if [ ${#word} -eq 0 ]; then
exit 1
fi
#Echo out ${word} and then pipe it through egrep to evaluate the pattern using regex to see if there are any vowels at the beginning of the string
vowel=`echo $word | egrep -E ^[aeiouAEIOU]`
#Echo out ${word} and then pipe it through sed to substitute any vowel at the beginning of the string with a blank space
vowel_translation=`echo "${word}" | sed 's/'^[aeiouAEIOU]'//'`
#Echo out ${word} and then pipe it through egrep to evaluate the pattern using regex to see if there are any consonants at the beginning of the string
consonant=`echo $word | egrep -E ^[^aeiouAEIOU]`
#Echo out ${word} and then pipe it through sed to substitute any consonant at the beginning of the string with a blank space
consonant_translation=`echo "${word}" | sed 's/'^[^aeiouAEIOU]'//'`
#Echo out ${word} and then pipe it through egrep to evaluate if there are any patterns of punctuation
sanitizing_punctuation=`echo $word | egrep -E [[:punct:]]`
#Echo out ${word} and then pipe it through egrep to evaluate if there are any patterns of numeric value 0-9
sanitizing_numbers=`echo $word | egrep -E [0-9]`

#Calling function
pig_latin 
#End of until loop
done

