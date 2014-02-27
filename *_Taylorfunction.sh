#!/bin/bash

#Setting the function pig_latin
function pig_latin () {
#Running if statement and using the -n comparison operator to basically say that if sanitizing_punctuation variable has a value or sanitizing_numbers has a value, then tell the users to enter valid characters A-Z
if [ -n "${sanitizing_punctuation}" ] || [ -n "${sanitizing_numbers}" ]  ; then
echo 'Please enter valid characters which would be A through Z';
#If the above statement is false then move to next if statement which says if vowel variable has a value then translate
elif [ -n "${vowel}" ]; then
echo 'Pig Latin Translation'
#Echo out vowel_translation value, then echo out the first letter of the value word and append way at the end of the string
echo ========"${vowel_translation}""${word:0:1}"'way'========;
#If the above statement is false then move to next if statement which says if consonant variable has a value then translate
elif [ -n "${consonant}" ]; then
echo 'Pig Latin Translation';
#Echo out consonant_translation value, then echo out the first letter of the value word and append way at the end of the string
echo ========"${consonant_translation}""${word:0:1}"'ay'========;
#End if structure
fi
#End of function
}

