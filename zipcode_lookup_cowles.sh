#!/bin/bash
#
#This script looks up the zip codes for the state abbreviation entered
# by the user from the keyboard.
#
# Include Functions
source ./zipcode_functions_cowles.sh
#
##Input file
#
INPUTFILE="zip_code_database.csv";
##
#Temporary delmiter used
TDEL='|'
#Delimiter output will use
DEL='","';
#The start of each output line
STLN='"';
#The end of each output line
ENDLN='"';
#
#Declare an associative array - note '-A'
#
declare -A State
#
#populate the array using the short state as key and long state as value
#
State[AL]='ALABAMA'
State[AK]='ALASKA'
State[AZ]='ARIZONA'
State[AR]='ARKANSAS'
State[CA]='CALIFORNIA'
State[CO]='COLORADO'
State[CT]='CONNECTICUT'
State[DE]='DELAWARE'
State[FL]='FLORIDA'
State[GA]='GEORGIA'
State[HI]='HAWAII'
State[ID]='IDAHO'
State[IL]='ILLINOIS'
State[IN]='INDIANA'
State[IA]='IOWA'
State[KS]='KANSAS'
State[KY]='KENTUCKY'
State[LA]='LOUISIANA'
State[ME]='MAINE'
State[MD]='MARYLAND'
State[MA]='MASSACHUSETTS'
State[MI]='MICHIGAN'
State[MN]='MINNESOTA'
State[MS]='MISSISSIPPI'
State[MO]='MISSOURI'
State[MT]='MONTANA'
State[NE]='NEBRASKA'
State[NV]='NEVADA'
State[NH]='NEW HAMPSHIRE'
State[NJ]='NEW JERSEY'
State[NM]='NEW MEXICO'
State[NY]='NEW YORK'
State[NC]='NORTH CAROLINA'
State[ND]='NORTH DAKOTA'
State[OH]='OHIO'
State[OK]='OKLAHOMA'
State[OR]='OREGON'
State[PA]='PENNSYLVANIA'
State[RI]='RHODE ISLAND'
State[SC]='SOUTH CAROLINA'
State[SD]='SOUTH DAKOTA'
State[TN]='TENNESSEE'
State[TX]='TEXAS'
State[UT]='UTAH'
State[VT]='VERMONT'
State[VA]='VIRGINIA'
State[WA]='WASHINGTON'
State[DC]='WASHINGTON DC'
State[WV]='WEST VIRGINIA'
State[WI]='WISCONSIN'
State[WY]='WYOMING'
selection="Test"
#loop until they do not enter anything
until [ selection == "" ]; do
  #get the stat abbreviation from the user
  echo -n "Enter a state abbreviation to look it up the related postal codes (or press enter to quit): "
  read selection
  #make sure they entered something ${#variable} gives the length of the value
  #If they didn't enter anything exit the loop
  if [ ${#selection} -eq 0 ]; then
    exit 1
    #they entered something so we'll check to see if it's valid and
    #display it with the first character capitalized and the rest
    #lower case using initcap function.
  else
    #First we will convert whatever they typed to upper case by using
    #the selection_2_UC function
    myselection=$(selection_2_UC $selection)
    if [ $(test_exists $myselection) -gt 0 ]; then
      #You need to use initcap on this line somewhere...
      echo "You selected State" $(initcap ${State[$myselection]})
      # Assign output file name based on state selected
      OUTFILE="${myselection}ZipCodeInformation.csv";
    fi
  fi
  #
  #Because of a weird quirk with the data and the read statement below
  #columns have quotes in them until we remove them
  #
  #The state we will be filtering for
  STATETOLOOKFOR=$myselection
  #Saving the original state of the internal field separator
  #This variable determines how Bash recognizes fields, or word
  #boundaries, when it interprets character strings.
  #We will save and set it back at the end
  OLDIFS=$IFS
  #We are splitting on ,
  #Note that I tried "," and it made no difference.
  #It is always best to save the internal field separator when changing it.
  #For more about IFS see http://tldp.org/LDP/abs/html/internalvariables.html
  IFS=,
  #Check if the INPUTFILE exists and echo a message and quit if it is not.
  [ ! -f $INPUTFILE ] && { echo "$INPUTFILE file not found"; exit 99; }
  #Check if the OUTFILE exists and remove it exists.
  #[ -f $OUTFILE ] && { echo "$OUTFILE already exists"; exit 99; }
  [ -f $OUTFILE ] && { rm -f $OUTFILE; }
  #Using while loop loop through each row of the INPUTFILE and assign
  # them to variables
  while read zipcode ztype primary_city acceptable_cities unacceptable_cities state county timezone area_codes latitude longitude world_region country decommissioned estimated_population notes
    do
    #Only write to the OUTFILE if it is the state we are looking for
	  # $state=echo "$state" | sed -e 's,",,g'
    if [ "$state" == '"'$STATETOLOOKFOR'"' ]; then
	    #fun use of sed.  Note there are multiple statements in the
            #same sed expression separated by ';'
	    #Also note that I am using the tr command to remove double quotes.
	    echo "${zipcode}${TDEL}${primary_city}${TDEL}${state}${TDEL}${timezone}${TDEL}${area_codes}${TDEL}${estimated_population}" | tr -d '"' | sed -e "s/$TDEL/$DEL/g;s/^/$STLN/g;s/$/$ENDLN/g;" >> $OUTFILE; # Print directly to the outputfile
    fi
  #End of while loop.  Note that it is this line that actually
  #specifies the INPUTFILE that the while loop is processing.
  done < $INPUTFILE
  echo File ="${myselection}ZipCodeInformation.csv has been created with the requested zip code information."
  IFS=$OLDIFS

#done with the until loop
done
