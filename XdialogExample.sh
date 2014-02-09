#!/bin/bash
declare -A State
State[AL]='ALABAMA'
State[AK]='ALASKA'
State[AZ]='ARIZONA'
State[AR]='ARKANSAS'
State[CA]='CALIFORNIA'
State[CO]='COLORADO'
State[CT]='CONNECTICUT'
State[DC]='WASHINGTON DC'
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
State[WV]='WEST VIRGINIA'
State[WI]='WISCONSIN'
State[WY]='WYOMING'
INPUTFILE="zip_code_database.csv";
TOUTFILE="zip_code_database.csv";
#Temporary delmiter used 
TDEL='|'
#Delimiter output will use
DEL='","';
#The start of each output line 
STLN='"';
#The end of each output line
ENDLN='"';
#########################
#FUNCTIONS
#########################
#
#dialog functions
#
function dialog_message(){
Xdialog --title 'Message' --msgbox "$*" 20 50
} 
function inititem(){
if [ $1 != "DC" ]; then
echo -n $1 | awk '{print toupper(substr($1,1,1)) tolower(substr($1,2))}'
else
echo -n $1  
fi
}
function dialog_yesno(){
Xdialog --title 'Message' --yesno "$*" 20 80
}
#
#Other functions
#
function inititem(){
if [ $1 != "DC" ]; then
echo -n $1 | awk '{print toupper(substr($1,1,1)) tolower(substr($1,2))}'
else
echo -n $1 
fi
}
function initcap() {
local loopcount=1
for variable in $*; do
	echo $(inititem $variable)
	#If the loopcount does not equal the last variable, then add a space
	if [ $loopcount -ne ${#*} ]; then 
		echo -n " "
	fi

	#Time to increment the loop counter
	((loopcount++))
done;
}
function sort_keys(){
for key in ${!State[@]}; do
	echo $key
done | sort -k1
}
function make_menulist(){ 
unset menulist; i=0
local -a state_key=$(sort_keys)
for key in ${state_key[@]}; do
 menulist[i++]=${State["$key"]}
 menulist[i++]=''

done 
}
function make_radiolist(){
unset radiolist; i=0
pair_count=0
local -a state_key=$(sort_keys)
for key in ${state_key[@]}; do
((pair_count))
 #radiolist[i++]=$pair_count
 radiolist[i++]="$key"
 radiolist[i++]=${State["$key"]}
 radiolist[i++]="off"
done
}
########################################
#End Functions
########################################
##############################
#Begin
##############################

#
#declare -a menulist
#make_menulist
#state_selected=$(Xdialog --backtitle "State Selection" --menu "Select State:" 12 40 10 "${menulist[@]}" 2>&1 >/dev/tty )
declare -a radiolist
#Create the array for the radiolist used in the dialog below
make_radiolist
#Get state abbreviation selection
STATETOLOOKFOR=$(Xdialog --backtitle "Select State Selection" --radiolist "Use arrow keys to choose\nPress space to choose selection\nPress enter to make selection.\nSelect State:" 20 40 30 "${radiolist[@]}" 2>&1 >/dev/tty )
#
#
#
statename=$(initcap ${State["$STATETOLOOKFOR"]})
dialog_yesno "You selected "$(initcap ${State["$STATETOLOOKFOR"]})"($STATETOLOOKFOR)\nWould you like to create a zip code file with just this state?" 
ok_proceed=$?
#
#Because of a weird quirk with the data and the read statement below columns have quotes in them until we remove them
#
OUTFILE=${STATETOLOOKFOR}${TOUTFILE}
STATETOLOOKFOR='"'$STATETOLOOKFOR'"'
#
#BEGIN
#Cant open input file CAzip_code_database.csv has been created with 2335 CAzip_code_database.csv lines.

if [ $ok_proceed -eq 1 ]; then
#user chose no
Xdialog --title 'Quitting' --msgbox "Hello, ${USER}\nYou have selected 'No'.\nThis program will now exit." 6 40
exit;
fi


#
#setting input and output file
#
#########################
#BEGIN CSV creation
#########################
#Saving the original state of the internal field separator
#This variable determines how Bash recognizes fields, or word boundaries, when it interprets character strings.
#We will save and set it back at the end
OLDIFS=$IFS
#We are splitting on ,
#Note that I tried "," and it made no difference.
#It is always best to save the internal field separator when changing it.
#For more about IFS see http://tldp.org/LDP/abs/html/internalvariables.html
IFS=,
#Check if the INPUTFILE exists and echo a message and quit if it is not.
[ ! -f $INPUTFILE ] && { Xdialog --title 'Message' --msgbox "$INPUTFILE file not found!\nTERMINATING PROGRAM.\n$OUTFILE not created." 20 50 ; exit 99; }
#Check if the OUTFILE exists and remove it exists.
#[ -f $OUTFILE ] && { echo "$OUTFILE already exists"; exit 99; }
[ -f $OUTFILE ] && { rm -f $OUTFILE; }

#Using while loop loop through each row of the INPUTFILE and assign them to variables
loopcount=0;
#zipcode ztype primary_city acceptable_cities unacceptable_cities state county timezone area_codes latitude longitude world_region country decommissioned estimated_population notes
#
#While loop that creates the output file
#
loopcount=0
#store output for tailboxbg to show
touch /tmp/Xdialog.$$
Xdialog --tailboxbg /tmp/Xdialog.$$ 40 40 &
while read zipcode ztype primary_city acceptable_cities unacceptable_cities state county timezone area_codes latitude longitude world_region country decommissioned estimated_population notes
	do

	#print out the header line to output file.
	if [ $loopcount -eq 0 ]; then
  	echo "${zipcode}${TDEL}${state}${TDEL}${area_codes}${TDEL}${timezone}" | tr -d '"' | sed -e "s/$TDEL/$DEL/g;s/^/$STLN/g;s/$/$ENDLN/g;" >> $OUTFILE; 
	fi 
        #
	#Only write to the OUTFILE if it is the state we are looking for
	#
	if [ "$state" == "$STATETOLOOKFOR" ]; then
	#fun use of sed.  Note there are multiple statements in the same sed expression separated by ';'
	#Also note that I am using the tr command to remove double quotes.
	# Print directly to the outputfile
	echo "${zipcode}${TDEL}${state}${TDEL}${area_codes}${TDEL}${timezone}" | tr -d '"' | sed -e "s/$TDEL/$DEL/g;s/^/$STLN/g;s/$/$ENDLN/g;" >> $OUTFILE; 
  	echo -n "+"
	else 
	echo -n "-"
	fi
	if [ $((loopcount%40)) -eq 0 ]; then
	echo " "
	fi
	#End of while loop.  Note that it is this line that actually specifies the INPUTFILE that the while loop is processing.
	((loopcount++))
done < $INPUTFILE >> /tmp/Xdialog.$$
echo 'Done.'  >> /tmp/Xdialog.$$
# Xdialog --progressbox
IFS=$OLDIFS
lines=$(cat $OUTFILE| wc -l)
dialog_yesno "The output file $OUTFILE has been created with $lines lines. Would you like to view it?" 
if [ $? -eq 0 ]; then
Xdialog --textbox $OUTFILE 40 80
else 
dialog_message "You selected No. You can view your file $OUTFILE later."
fi
clear;
ls -l $OUTFILE
