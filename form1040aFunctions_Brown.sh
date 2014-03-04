#!/bin/bash

# This is a simple tax Form 1040a
#
# Final Project Requirements
# Loop: for, until, or while ........................... Check
# Variables: integer AND string ........................ Check
# Input Validation: Files exist, input is correct ...... Check
# Functions: At least one function ..................... Check
# Decision Structure: if/then, or case ................. Check
# OS Command: some linux OS command .................... Check
# Comments: ............................................ Check

tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/temporary.$$

# cleanup  - add a trap that will remove $tempfile
# if any of the signals - SIGHUP SIGINT SIGTERM it received.
trap "rm $tempfile; exit" SIGHUP SIGINT SIGTERM

# Verify that the parameter is, in fact, a number
function isANumber () {
    re='^[0-9]+$'
    numberToTest=$1
    if ! [[ $numberToTest =~ $re ]] ; then
        echo 0
    else
        echo 1
    fi
}

# Remove special characters from the input parameter
function removeSpecialChars () { 
    echo $@ | sed 's/[._-]//g'
}

# Convert the input parameter to a currency format for displaying
function convertToCurrency () {
    echo $1 | awk '{printf "$%.2f", $1}'
}

# Gather personal information about the user.
# This isn't functionally useful for the script, but it makes the script feature-complete in accordance with the Form 1040a tax form.

# Gather the name information
function determineName () {
    clear
    dialog --title "Name" \
    --nocancel \
    --form "Enter your name: " \
    10 50 0 \
    "First Name: " 1 1 "$firstName"    1 16 20 0 \
    "Middle Initial: " 2 1 "$middleInitial"    2 16 1 0 \
    "Last Name: " 3 1 "$lastName"    3 16 20 0 \
    2>$tempfile
    
    firstName=$(removeSpecialChars `head -n1 $tempfile`)
    middleInitial=$(removeSpecialChars `head -n2 $tempfile | tail -n1`)
    lastName=$(removeSpecialChars `tail -n1 $tempfile`)
    
    if [ $firstName -z ] || [ $lastName -z ]; then
       determineName
    fi
}

# Set the socialSecurityNumber variable
function determineSocial () {
    clear
    dialog --title "Social Security Number" \
    --nocancel \
    --inputbox "Enter your social security number. An incorrect or missing SSN can increase your tax, reduce your refund, or delay your refund.\n\nWhile this script does not store any information beyond its lifetime, it is recommended that you DO NOT enter your actual SSN." \
    11 80 2>$tempfile

    socialSecurityNumber=`cat $tempfile`  # Optional - put in a fake number. Not a federally official program.
    
    socialSecurityNumber=`cat $tempfile | sed 's/[^0-9]//g'`

    if [ -z $socialSecurityNumber ] || [ ${#socialSecurityNumber} -ne 9 ]; then
        determineSocial
    fi
}

# Set the address information
function determineAddress () {
    clear
    dialog --title "Address" \
    --nocancel \
    --form "Enter your Address: \n\nLeave blank section that isn't relevant" \
    20 80 0 \
    "Street Address: " 1 1 "$streetAddress"    1 40 20 0 \
    "Apartment Number: " 2 1 "$aptNo"    2 40 5 0 \
    "City: " 3 1 "$city"    3 40 20 0 \
    "State: " 4 1 "$state"    4 40 20 0 \
    "Zip Code: " 5 1  "$zipCode"    5 40 5 0 \
    "Foreign Country Name: " 6 1 "$foreignCountryName"    6 40 20 0 \
    "Foreign Province: " 7 1 "$foreignProvince"    7 40 20 0 \
    "Foreign Postal Code: " 8 1 "$foreignPostalCode"    8 40 20 0 \
    2>$tempfile
    
    streetAddress=$(removeSpecialChars `head -n1 $tempfile`)
    aptNo=$(removeSpecialChars `tail -n+2 $tempfile | head -n1`)
    city=$(removeSpecialChars `tail -n+3 $tempfile | head -n1`)
    state=$(removeSpecialChars `tail -n+4 $tempfile | head -n1`)
    zipCode=$(removeSpecialChars `tail -n+5 $tempfile | head -n1`)
    foreignCountryName=$(removeSpecialChars `tail -n+6 $tempfile | head -n1`)
    foreignProvince=$(removeSpecialChars `tail -n+7 $tempfile | head -n1`)
    foreignPostalCode=$(removeSpecialChars `tail -n+8 $tempfile`)
    
    if [ -z $streetAddress ] || [ -z $city ] || [ -z $state ] || [ -z $zipCode ]; then
       determineAddress
    fi
}

# Verify section one's information
function verifySectionOne () {
    dialog --backtitle "Verify" \
    --nocancel \
    --radiolist "Verify that the information is correct. When everything is correct, select continue." \
    18 70 18 \
    1 "Name: $firstName $middleInitial $lastName" off \
    2 "Social Security Number: $socialSecurityNumber" off \
    3 "Address: $streetAddress" off \
    4 "Apartment Number: $aptNo" off \
    5 "City: $city" off \
    6 "State: $state" off \
    7 "Zip Code: $zipCode" off \
    8 "Foreign Country Name: $foreignCountryName" off \
    9 "Foreign Province: $foreignProvince" off \
    10 "Foreign Postal Code: $foreignPostalCode" off \
    11 "Continue" on \
    2>$tempfile
    
    selection=`cat $tempfile`

    exitStatus=1
    while [ ! $exitStatus -eq 0 ]; do
        case $selection in 
        1)
            determineName
            verifySectionOne
            ;;
        2)
            determineSocial
            verifySectionOne
            ;;
        3)
            determineAddress
            verifySectionOne
            ;;
        4)
            determineAddress
            verifySectionOne
            ;;
        5)
            determineAddress
            verifySectionOne
            ;;
        6)
            determineAddress
            verifySectionOne
            ;;
        7)
            determineAddress
            verifySectionOne
            ;;
        8)
            determineAddress
            verifySectionOne
            ;;
        9)
            determineAddress
            verifySectionOne
            ;;
        10)
            determineAddress
            verifySectionOne
            ;;
        11)
            exitStatus=0
            ;;
        *)
            verifySectionOne
            ;;
    esac
    done
}

# Item 1-5
# Set the filingStatus variable
function determineFilingStatus () {
    clear
    dialog --backtitle "Filing Status" \
    --nocancel \
    --radiolist "Select Filing Status: " 11 40 4 \
        1 "Single" on \
        2 "Married, Filing Jointly" off \
        3 "Married, Filing Seperately" off \
        4 "Head of Household" off 2>$tempfile
    filingStatus=`cat $tempfile`
}

# Item 6a-6d
# Set the numExemptions variable
function determineExemptions () {
    clear
    dialog --title "Number of Exemptions" \
    --nocancel \
    --inputbox "Enter the number of exemptions you're claiming. \n
If noone is claiming you, you can claim one. \n
If you are claiming your spouse, add another. \n
If you are claiming and dependants, such as children, add 1 for each. 
Enter a Number.\n" \
    11 80 2>$tempfile

    numExemptions=`cat $tempfile`
    
    if [ $(isANumber $numExemptions) -eq 0 ]; then
        determineExemptions
    fi
}

# Item 7
# Set the income variable
function determineIncome () {
    clear
    dialog --title "Income" \
    --nocancel \
    --inputbox "Enter the total of your wages, salaries, tips, etc. If a joint return, also include your spouse's income. For most people, the amount to enter on this line should be shown in box 1 of their Form(s) W-2. But the following types of income must also be included in the total on line 7." \
    10 80 2>$tempfile

    income=`cat $tempfile`

    if [ $(isANumber $income) -eq 0 ]; then
        determineIncome
    fi
}

# Item 8a
# Set the taxableInterest variable
function determineTaxableInterest () {
    clear
    dialog --title "Taxable Interest" \
    --nocancel \
    --inputbox "Each payer should send you a Form 1099-INT or Form 1099-OID. Enter your total taxable interest income, but you must fill in and attach Schedule B if the total is over \$1,500 or any of the other conditions listed at the beginning of the Schedule B instructions apply to you." \
    10 80 2>$tempfile

    taxableInterest=`cat $tempfile`

    if [ $(isANumber $taxableInterest) -eq 0 ]; then
        determineTaxableInterest
    fi
}

# Item 8b
# Set the taxExemptInterest variable
function determineTaxExemptInterest () {
    clear
    dialog --title "Tax-Exempt Interest" \
    --nocancel \
    --inputbox "If you received any tax-exempt interest, such as from municipal bonds, each payer should send you a Form 1099-INT. Your tax-exempt interest should be shown in box 8 of Form 1099-INT. Enter the total on line 8b. Also include any exempt-interest dividends from a mutual fund or other regulated investment company. This amount should be shown in box 10 of Form 1099-DIV." \
    11 80 2>$tempfile

    taxExemptInterest=`cat $tempfile`

    if [ $(isANumber $taxExemptInterest) -eq 0 ]; then
        determineTaxExemptInterest
    fi
}

# Item 9a
# Set the ordinaryDividends variable
function determineOrdinaryDividends () {
    clear
    dialog --title "Ordinary Dividends" \
    --nocancel \
    --inputbox "Each payer should send you a Form 1099-DIV. Enter your total ordinary dividends on line 9a. This amount should be shown in box 1a of Form(s) 1099-DIV." \
    9 80 2>$tempfile

    ordinaryDividends=`cat $tempfile`

    if [ $(isANumber $ordinaryDividends) -eq 0 ]; then
        determineOrdinaryDividends
    fi
}

# Item 9b
# Set the qualifiedDividends variable
function determineQualifiedDividends () {
    clear
    dialog --title "Qualified Dividends" \
    --nocancel \
    --inputbox "Enter your total qualified dividends. Qualified dividends are also included in the ordinary dividend total required to be shown in the previous window. Qualified dividends are eligible for a lower tax rate than other ordinary income. Generally, these dividends are shown in box 1b of Form(s) 1099-DIV. See Pub. 550 for the definition of qualified dividends if you received dividends not reported on Form 1099-DIV." \
    12 80 2>$tempfile

    qualifiedDividends=`cat $tempfile`

    if [ $(isANumber $qualifiedDividends) -eq 0 ]; then
        determineQualifiedDividends
    fi
}

# Item 10
# Set the capitalGains variable
function determineCapitalGain () {
    clear
    dialog --title "Capital Gains" \
    --nocancel \
    --inputbox "Each payer should send you a Form 1099-DIV. If you received capital gain distributions as a nominee (that is, they were paid to you but actually belong to someone else), report in the box only the amount that belongs to you. Include a statement showing the full amount you received and the amount you received as a nominee. See the Schedule B instructions for filing requirements for Forms 1099-DIV and 1096." \
    12 80 2>$tempfile

    capitalGains=`cat $tempfile`

    if [ $(isANumber $capitalGains) -eq 0 ]; then
        determineCapitalGain
    fi
}

# Item 11a
# Set the IRADistributions variable
function determineIRADistributions () {
    clear
    dialog --title "IRA Distributions" \
    --nocancel \
    --inputbox "You should receive a Form 1099-R showing the total amount of any distribution from your IRA before income tax and other deductions were withheld. This amount should be shown in box 1 of Form 1099-R." \
    9 80 2>$tempfile

    IRADistributions=`cat $tempfile`

    if [ $(isANumber $IRADistributions) -eq 0 ]; then
        determineIRADistributions
    fi
}

# Item 11b
# Set the taxableIRADistributions variable
function determineTaxableIRADistributions () {
    clear
    dialog --title "Taxable IRA Distributions" \
    --nocancel \
    --inputbox "See the instructions for the Form 1040a." \
    7 80 2>$tempfile

    taxableIRADistributions=`cat $tempfile`

    if [ $(isANumber $taxableIRADistributions) -eq 0 ]; then
        determineTaxableIRADistributions
    fi
}

# Item 12a
# Set the pensions variable
function determinePensions () {
    clear
    dialog --title "Pensions and Annuities" \
    --nocancel \
    --inputbox "You should receive a Form 1099-R showing the total amount of your pension and annuity payments before income tax or other deductions were withheld. This amount should be shown in box 1 of Form 1099-R. Pension and annuity payments include distributions from 401(k), 403(b), and governmental 457(b) plans." \
    11 80 2>$tempfile

    pensions=`cat $tempfile`

    if [ $(isANumber $pensions) -eq 0 ]; then
        determinePensions
    fi
}

# Item 12b
# Set the taxablePensions variable
function determineTaxablePensions () {
    clear
    dialog --title "Taxable Pensions and Annuities" \
    --nocancel \
    --inputbox "See the instrictions for the Form 1040a." \
    7 80 2>$tempfile

    taxablePensions=`cat $tempfile`

    if [ $(isANumber $taxablePensions) -eq 0 ]; then
        determineTaxablePensions
    fi
}

# Item 13
# Set the unemploymentComp variable
function determineUnemployment () {
    clear
    dialog --title "Unemployment Compensation" \
    --nocancel \
    --inputbox "You should receive a Form 1099-G showing in box 1 the total unemployment compensation paid to you in 2013. Report this amount here. However, if you made contributions to a governmental unemployment compensation program or to a governmental paid family leave program, reduce the amount you report here by those contributions." \
    11 80 2>$tempfile

    unemploymentComp=`cat $tempfile`

    if [ $(isANumber $unemploymentComp) -eq 0 ]; then
        determineUnemployment
    fi
}

# Item 14a
# Set the socSecBenefits variable
function determineSocSec () {
    clear
    dialog --title "Social Security Benefits" \
    --nocancel \
    --inputbox "You should receive a Form SSA-1099 showing in box 3 the total social security benefits paid to you. Box 4 will show the amount of any benefits you repaid in 2013. If you received railroad retirement benefits treated as social security, you should receive a Form RRB-1099.

See the instructions for more information on the ammount to enter here." \
    12 80 2>$tempfile

    socSecBenefits=`cat $tempfile`

    if [ $(isANumber $socSecBenefits) -eq 0 ]; then
        determineSocSec
    fi
}

# Item 14b
# Set the taxSocSecBenefits variable
function determineTaxableSocSec () {
    clear
    dialog --title "Taxable Social Security Benefits" \
    --nocancel \
    --inputbox "See the instructions for Form 1040a." \
    7 80 2>$tempfile

    taxSocSecBenefits=`cat $tempfile`

    if [ $(isANumber $taxSocSecBenefits) -eq 0 ]; then
        determineTaxableSocSec
    fi
}

# Verify section two's information
function verifySectionTwo () {
    dialog --backtitle "Verify" \
    --nocancel \
    --radiolist "Verify Information" \
    18 70 18 \
    1 "Filing status: $filingStatus" off \
    2 "Number of Exemptions: $numExemptions" off \
    3 "Income: $income" off \
    4 "Taxable Interest: $taxableInterest" off \
    5 "Tax-exempt Interest: $taxExemptInterest" off \
    6 "Ordinary Dividends: $ordinaryDividends" off \
    7 "Qualified Dividends: $qualifiedDividends" off \
    8 "Capital gain distributions: $capitalGains" off \
    9 "IRA Distributions: $IRADistributions" off \
    10 "Taxable IRA Distributions: $taxableIRADistributions" off \
    11 "Pensions and Annuities: $pensions" off \
    12 "Taxable Pensions and Annuities: $taxablePensions" off \
    13 "Unemployment compensation and Alaska Fund dividends: $unemploymentComp" off \
    14 "Social Security Benefits: $socSecBenefits" off \
    15 "Taxable Social Security Benefits: $taxSocSecBenefits" off \
    16 "Continue" on \
    2>$tempfile
    
    selection=`cat $tempfile`

    exitStatus=1
    while [ ! $exitStatus -eq 0 ]; do
        case $selection in 
        1)
            determineFilingStatus
            verifySectionTwo
            ;;
        2)
            determineExemptions
            verifySectionTwo
            ;;
        3)
            determineIncome
            verifySectionTwo
            ;;
        4)
            determineTaxableInterest
            verifySectionTwo
            ;;
        5)
            determineTaxExemptInterest
            verifySectionTwo
            ;;
        6)
            determineOrdinaryDividends
            verifySectionTwo
            ;;
        7)
            determineQualifiedDividends
            verifySectionTwo
            ;;
        8)
            determineCapitalGain
            verifySectionTwo
            ;;
        9)
            determineIRADistributions
            verifySectionTwo
            ;;
        10)
            determineTaxableIRADistributions
            verifySectionTwo
            ;;
        11)
            determinePensions
            verifySectionTwo
            ;;
        12)
            determineTaxablePensions
            verifySectionTwo
            ;;
        13)
            determineUnemployment
            verifySectionTwo
            ;;
        14)
            determineSocSec
            verifySectionTwo
            ;;
        15)
            determineTaxableSocSec
            verifySectionTwo
            ;;
        16)
            exitStatus=0
            ;;
        *)
            verifySectionTwo
            ;;
    esac
    done
}

# Item 15 - Taxable Income
# Show taxableIncome variable
function displayTaxableIncome () {
    taxableIncome=$(($income+$taxableInterest+$ordinaryDividends+$capitalGainDistributions+$taxableIRADistributions+$taxablePensions+$unemploymentComp+$taxSocSecBenefits))

    dialog --title "Taxable Income" \
    --msgbox "Your total taxable income is: $(convertToCurrency $taxableIncome) \n\nThis was calculated by adding your income, taxable interest, ordinary dividends, capital gains distributions, taxable IRA distributions, taxable pensions and annuitites, unemployment compensation, and taxable social security benefits." \
    10 80
}

# Item 16
# Set the educatorExpenses variable
function determineEducatorExpenses () {
    clear
    dialog --title "Educator Expenses" \
    --nocancel \
    --inputbox "If you were an eligible educator in 2013, you can deduct on here up to \$250 of qualified expenses you paid in 2013. If you and your spouse are filing jointly and both of you were eligible educators, the maximum deduction is \$500. However, neither spouse can deduct more than \$250 of his or her qualified expenses here. You may be able to deduct expenses that are more than the \$250 (or \$500) limit on Schedule A, line 21, but you must use Form 1040. An eligible educator is a kindergarten through grade 12 teacher, instructor, counselor, principal, or aide who worked in a school for at least 900 hours during a school year." \
    15 80 2>$tempfile

    educatorExpenses=`cat $tempfile`

    if [ $(isANumber $educatorExpenses) -eq 0 ]; then
        determineEducatorExpenses
    fi
}

# Item 17
# Set the IRADeductions variable
function determineIRADeductions () {
    clear
    dialog --title "IRA Deductions" \
    --nocancel \
    --inputbox "If you made contributions to a traditional IRA for 2013, you may be able to take an IRA deduction. But you, or your spouse if filing a joint return, must have had earned income to do so. See the instructions to determine the amount." \
    10 80 2>$tempfile

    IRADeductions=`cat $tempfile`
    
    if [ $(isANumber $IRADeductions) -eq 0 ]; then
        determineIRADeductions
    fi
}

# Item 18
# Set the studentLoanInterestDeductions variable
function determineStudentLoanInterestDeductions () {
    clear
    dialog --title "Student Loan Interest Deduction" \
    --nocancel \
    --inputbox "You can take this deduction only if all of the following apply. \n\nYou paid interest in 2013 on a qualified student loan (defined later). \n\nYour filing status is any status except married filing separately. \n\nYour modified adjusted gross income (AGI) is less than: \n\$75,000 if single, head of household, or qualifying widow(er); \n\$155,000 if married filing jointly. Use lines 2 through 4 of the Student Loan Interest Deduction Worksheet to figure your modified AGI. \n\nYou, or your spouse if filing jointly, are not claimed as a dependent on someone's (such as your parent's) 2013 tax return." \
    19 80 2>$tempfile

    studentLoanInterestDeductions=`cat $tempfile`
    
    if [ $(isANumber $studentLoanInterestDeductions) -eq 0 ]; then
        determineStudentLoanInterestDeductions
    fi
}

# Item 19
# Set the tuitionAndFees variable
function determineTuitionAndFees () {
    clear
    dialog --title "Tuition and Fees" \
    --nocancel \
    --inputbox "If you paid qualified tuition and fees for yourself, your spouse, or your dependent(s), you may be able to take this deduction. \n\nSee Form 8917." \
    10 80 2>$tempfile

    tuitionAndFees=`cat $tempfile`
    
    if [ $(isANumber $tuitionAndFees) -eq 0 ]; then
        determineTuitionAndFees
    fi
}

# Item 20
# Set the adjGrossIncome variable
function displayTotalAdjustments () {
    totalAdjustments=$(($educatorExpenses+$IRADeductions+$studentLoanInterestDeductions+$tuitionAndFees))
   
# 21 - 22
    adjGrossIncome=$(($income-$totalAdjustments))
   
    dialog --title "Total Adjustments" \
    --msgbox "Your total adjustments are: $totalAdjustments \n\nYour adjusted gross income is: $adjGrossIncome" \
    7 80
}

# Verify section three's information
function verifySectionThree () {
    dialog --backtitle "Verify" \
    --nocancel \
    --radiolist "Verify that the information is correct. When everything is correct, select continue." \
    13 70 18 \
    1 "Educator Expenses: $educatorExpenses" off \
    2 "IRA Deductions: $IRADeductions" off \
    3 "Student Loan Interest Deductions: $studentLoanInterestDeductions" off \
    4 "Tuition and Fees: $tuitionAndFees" off \
    5 "Continue" on \
    2>$tempfile
    
    selection=`cat $tempfile`

    exitStatus=1
    while [ ! $exitStatus -eq 0 ]; do
        case $selection in 
        1)
            determineEducatorExpenses
            verifySectionThree
            ;;
        2)
            determineIRADeductions
            verifySectionThree
            ;;
        3)
            determineStudentLoanInterestDeductions
            verifySectionThree
            ;;
        4)
            determineTuitionAndFees
            verifySectionThree
            ;;
        5)
            exitStatus=0
            ;;
        *)
            verifySectionThree
            ;;
    esac
    done
}

# 23a
# Various options that may apply to a person. Used to calculate the standard deduction later
function twentyThreeA () {
    dialog --title "" \
    --nocancel \
    --checklist "Check any that apply: " 10 80 4\
    1 "You were born before January 2, 1949" off \
    2 "You are blind" off \
    3 "Your spouse was born before January 2, 1949" off \
    4 "You spouse is blind" off \
    2>$tempfile

    data=`sed 's/[^0-9]//g' $tempfile`

    twentyThreeA="${#data}"
}

# Item 23b - 24
# Ask the user if they want to do itemized deductions
function ensureNonItemized () {
    clear
    dialog --title "Ensure Non-Itemized" \
    --nocancel \
    --yesno "The Form 1040a does not allow you to itemize your deductions. \n\nAre you sure you want to continue?" \
    7 80 2>$tempfile

    cont=`cat $tempfile`
    
    if [[ $cont -eq 1 ]]; then
        dialog \
        --nocancel \
        --msgbox "Form cancelled." \
        7 80
        exit
    fi
}

# Set the tax bracketting based on filingStatus and display to user
function displayStandardDeduction () {
    case $filingStatus in
        1)  # Tax Bracketting for Single
            tax10=0	# Tax 10% from 0 to 8925	for single status
            tax15=8925	# Tax 15% from 8926 to 36250	for single status
            tax25=36250	# Tax 25% from 36251 to 87850	for single status
            tax28=87850	# Tax 28% from 87851 to 183250	for single status
            tax33=183250 # Tax 33% from 183251 to 398350 for single status
            tax35=398350 # Tax 35% from 398351 t0 400000 for single status
            tax39=400000 # Tax 39.6% from 400001+	 for single status

            if [ "$twentyThreeA" -eq 2 ]; then
                standardDeduction=9100
            elif [ "$twentyThreeA" -eq 1]; then
                standardDeduction=7600
            else
                standardDeduction=6100
            fi
        ;;
        2)  # Tax Bracketting for Married Filing Jointly
            tax10=0
            tax15=17850
            tax25=72500
            tax28=146400
            tax33=223350
            tax35=398350
            tax39=450000
            
            if [ $twentyThreeA -eq 4 ]; then
                standardDeduction=17000
            elif [ $twentyThreeA -eq 3 ]; then
                standardDeduction=15800
            elif [ $twentyThreeA -eq 2 ]; then
                standardDeduction=14600
            elif [ $twentyThreeA -eq 1 ]; then
                standardDeduction=13400
            else           
                standardDeduction=12200
            fi
        ;;
        3)  # Tax Bracketting for Married Filing Seperately
            tax10=0
            tax15=8925
            tax25=36250
            tax28=73200
            tax33=111525
            tax35=199175
            tax39=225000
       
            dialog --title "Itemization" \
            --nocancel \
            --yesno  "Is your spouse doing itemized deductions?" \
            7 80 2>$tempfile

            spouseItemizes=`cat $tempfile`

            if [ $spouseItemizes -eq 0 ]; then
                standardDeduction=0
            else
                if [ $twentyThreeA -eq 4 ]; then
                    standardDeduction=10900
                elif [ $twentyThreeA -eq 3 ]; then
                    standardDeduction=9700
                elif [ $twentyThreeA -eq 2 ]; then
                    standardDeduction=8500
                elif [ $twentyThreeA -eq 1 ]; then
                    standardDeduction=7300
                else           
                    standardDeduction=6100
                fi
            fi
        ;;
        4)  # Tax Bracketting for Head of Household
            tax10=0
            tax15=12750
            tax25=48600
            tax28=125450
            tax33=203150
            tax35=398350
            tax39=425000

            if [ $twentyThreeA -eq 2 ]; then
                standardDeduction=11950
            elif [$twentyThreeA -eq 1 ]; then
                standardDeduction=10450
            else
                standardDeduction=8950
            fi
        ;;
        *)
        ;;
    esac

    dialog --title "Tax Bracket and Standard Deduction" \
    --msgbox "Your standard deduction is: $(convertToCurrency $standardDeduction) \n\nYour tax bracketting is as follows:\n\n$tax10->$tax15	|	Taxed at %10\n$tax15->$tax25	|	Taxed at 15%\n$tax25->$tax28	|	Taxed at 25%\n$tax28->$tax33	|	Taxed at 28%\n$tax33->$tax35	|	Taxed at 33%\n$tax35->$tax39	|	Taxed at 35%\n$tax39+	|	Taxed at 39%" \
    15 60
}

# Item 25
# Display Exemption credits
function displayExemptionsCredits () {
    if [[ $standardDeduction -gt $adjGrossIncome ]]; then
        taxableIncome=0
    elif [[ $standardDeduction -lt $adjGrossIncome ]]; then
        taxableIncome=$(($adjGrossIncome-$standardDeduction))
    fi

# Item 26
    exemptions=$(($numExemptions*3900))

    dialog --title "Exemption Credits" \
    --msgbox "Your total exemption credits: $(convertToCurrency $exemptions)" \
    7 50
}

# Item 27
# Calculate taxes owed based on income
function determineTaxes () {
    if [[ $exemptions -gt $taxableIncome ]]; then
        taxableIncome=0
    elif [[ $exemptions -lt $taxableIncome ]]; then
        taxableIncome=$((taxableIncome-$exemptions))
    fi

# Item 28
# 39.6% Bracket
    if [ $taxableIncome -gt $tax39 ]; then
        taxable=$(($taxableIncome-$tax39))
        taxOwed=$(($taxable*396/1000))
#       echo "$taxOwed owed on $taxable greater than $tax39"
        taxableIncome=$tax39
    fi

# 35% Bracket
    if [ $taxableIncome -gt $tax35 ]; then
        taxable=$(($taxableIncome-$tax35))
        taxOwed=$(($taxOwed + $(($taxable*35/100))))
#       echo "$taxOwed owed on $taxable greater than $tax35"
        taxableIncome=$tax35
    fi

# 33% Bracket
    if [ $taxableIncome -gt $tax33 ]; then
        taxable=$(($taxableIncome-$tax33))
        taxOwed=$(($taxOwed + $(($taxable*33/100))))
#       echo "$taxOwed owed on $taxable greater than $tax33"
        taxableIncome=$tax33
    fi

# 28% Bracket
    if [ $taxableIncome -gt $tax28 ]; then
        taxable=$(($taxableIncome-$tax28))
        taxOwed=$(($taxOwed + $(($taxable*28/100))))
#       echo "$taxOwed owed on $taxable greater than $tax28"
        taxableIncome=$tax28
    fi

# 25% Bracket
    if [ $taxableIncome -gt $tax25 ]; then
        taxable=$(($taxableIncome-$tax25))
        taxOwed=$(($taxOwed + $(($taxable*25/100))))
#       echo "$taxOwed owed on $taxable greater than $tax25"
        taxableIncome=$tax25
    fi

# 15% Bracket
    if [ $taxableIncome -gt $tax15 ]; then
        taxable=$(($taxableIncome-$tax15))
        taxOwed=$(($taxOwed + $(($taxable*15/100))))
#       echo "$taxOwed owed on $taxable greater than $tax15"
        taxableIncome=$tax15
    fi

# 10% Bracket
    if [ $taxableIncome -gt $tax10 ]; then
        taxable=$(($taxableIncome-$tax10))
        taxOwed=$(($taxOwed + $(($taxable*10/100))))
#       echo "$taxOwed owed on $taxable greater than $tax10"
        taxableIncome=$tax10
    fi

    dialog --title "Tax Owed" \
    --msgbox "Your tax owed is: $(convertToCurrency $taxOwed)" \
    6 40
}

# 29
function determineChildCareCredit () {
    clear
    dialog --title "Credit for Child and Dependent Care Expenses" \
    --nocancel \
    --inputbox "You may be able to take this credit if you paid someone to care
for any of the following persons.\n1. Your qualifying child under age 13 whom you claim as your dependent.\n2. Your disabled spouse or any other disabled person who could not care for himself or herself.\n3. Your child whom you could not claim as a dependent because of the rules for Children of divorced or separated parents in the instructions for line 6c." \
    14 80 2>$tempfile

    dependentCredit=`cat $tempfile`
    
    if [ $(isANumber $dependentCredit) -eq 0 ]; then
        determineChildCareCredit
    fi
}

# Item 30
# Set the elderlyCredits variable
function determineElderlyCredit () {
    clear
    dialog --title "Credit for the Elderly or Disabled" \
    --nocancel \
    --inputbox "You may be able to take this credit if by the end of 2013 (a) you were age 65 or older, or (b) you retired on permanent and total disability and you had taxable disability income." \
    9 80 2>$tempfile

    elderlyCredit=`cat $tempfile`
    
    if [[ $(isANumber $elderlyCredit) -eq 0 ]]; then
        determineElderlyCredit
    fi
}

# Item 31
# Set the educationCredits variable
function determineEducationCredit () {
    clear
    dialog --title "Education Credits from Form 8863" \
    --nocancel \
    --inputbox "If you (or your dependent) paid qualified expenses in 2013 for yourself, your spouse, or your dependent to enroll in or attend an eligible educational institution, you may be able to take an education credit. See Form 8863 for details." \
    10 80 2>$tempfile

    educationCredits=`cat $tempfile`
    
    if [[ $(isANumber $educationCredits) -eq 0 ]]; then
        determineEducationCredit
    fi
}

# Item 32
# Set the retirementCredit variable
function determineRetirementCredit () {
    clear
    dialog --title "Retirement Savings Contribution Credit" \
    --nocancel \
    --inputbox "You may be able to take this credit if you, or your spouse filing jointly, made (a) contributions, other than rollover contributions, to a traditional or Roth IRA; (b) elective deferrals to a 401(k) or 403(b) plan (including designated Roth contribu-tions), or to a governmental 457, SEP, or SIMPLE plan; (c) voluntary employee contributions to a qualified retirement plan (including the federal Thrift Savings Plan); or (d) contributions to a 501(c)(18)(D) plan." \
    13 80 2>$tempfile

    retirementCredit=`cat $tempfile`
    
    if [ $(isANumber $retirementCredit) -eq 0 ]; then
        determineRetirementCredit
    fi
}

# Item 33
# Set the childTaxCredit variable
function determineChildTaxCredit () {
    clear
    dialog --title "Child Tax Credit" \
    --nocancel \
    --inputbox "See insructions." \
    8 40 2>$tempfile

    childTaxCredit=`cat $tempfile`
    
    if [ $(isANumber $childTaxCredit) -eq 0 ]; then
        determineChildTaxCredit
    fi
}

# Verify the fourth section
function verifySectionFour () {
    dialog --backtitle "Verify" \
    --nocancel \
    --radiolist "Verify that the information is correct. When everything is correct, select continue." \
    13 70 18 \
    1 "Child Care Credit: $dependentCredit" off \
    2 "Credit for the Elderly: $elderlyCredit" off \
    3 "Education Credit: $educationCredits" off \
    4 "Retirement Savings Credit: $retirementCredit" off \
    5 "Child Tax Credit: $childTaxCredit" off \
    6 "Continue" on \
    2>$tempfile
    
    selection=`cat $tempfile`

    exitStatus=1
    while [ ! $exitStatus -eq 0 ]; do
        case $selection in 
        1)
            determineChildCareCredit
            verifySectionFour
            ;;
        2)
            determineElderlyCredit
            verifySectionFour
            ;;
        3)
            determineEducationCredit
            verifySectionFour
            ;;
        4)
            determineRetirementCredit
            verifySectionFour
            ;;
        5)
            determineChildTaxCredit
            verifySectionFour
            ;;
        6)
            exitStatus=0
            ;;
        *)
            verifySectionFour
            ;;
    esac
    done
}

# Item 34
# Display the totalCredits
function displayTotalCredits () {
    totalCredits=$(($dependentCredit+$elderlyCredit+$educationCredit+$retirementCredit+$childTaxCredit))
    
    if [ $(totalCredits) -lt 1 ]; then
        totalCredits=0
    fi
    
    dialog --title "Tax Credits" \
    --msgbox "Your total credits are $totalCredits" \
    6 40
}

# Item 35
# Calculate the total adjusted tax
function displayAdjustedTax () {
    if [ $totalCredits -gt $taxOwed ]; then
        totalTax=0
        dialog --title "Adjusted Tax" \
        --msgbox "Your adjusted total tax is 0." \
        7 40
    elif [ $totalCredits -lt $taxOwed ]; then
        totalTax=$(($taxOwed-$totalCredits))
        dialog --title "Adjusted Tax" \
        --msgbox "Your adjusted total tax is $totalTax" \
        7 40
    fi
}

# Item 36
# Set the taxWithheld variable
function determineWithheldTax () {
    clear
    dialog --title "Tax Withheld" \
    --nocancel \
    --inputbox "Add the amounts shown as federal income tax withheld on your Forms W-2 and 1099-R. Enter the total on line 36. The amount withheld should be shown in box 2 of Form W-2, and in box 4 of Form 1099-R. Attach Form(s) 1099-R to the front of your return if federal income tax was withheld." \
    10 80 2>$tempfile

    taxWithheld=`cat $tempfile`
    
    if [ $(isANumber $taxWithheld) -eq 0 ]; then
        determineWithheldTax
    fi
}

# Item 37
# Set the paymentFrom2012 variable
function determineAppliedTax () {
    clear
    dialog --title "Tax Applied from 2012" \
    --nocancel \
    --inputbox "Enter any estimated federal income tax payments you made for 2013. Include any overpayment that you applied to your 2013 estimated tax from: Your 2012 return, or An amended return (Form 1040X)." \
    9 80 2>$tempfile

    paymentFrom2012=`cat $tempfile`
    
    if [ $(isANumber $paymentFrom2012) -eq 0 ]; then
        determineAppliedTax
    fi
}

# Item 38a
# Set the EIC variable
function determineEIC () {
    clear
    dialog --title "Earned Income Credit" \
    --nocancel \
    --inputbox "The EIC is a credit for certain people who work. The credit may give you a refund even if you do not owe any tax or did not have any tax withheld.\n\nSee the instructions to determine the amount." \
    10 80 2>$tempfile

    EIC=`cat $tempfile`
    
    if [ $(isANumber $EIC) -eq 0 ]; then
        determineEIC
    fi
}

# Item 38b
# Set the nontaxableCombat variable
function determineNontaxCombat () {
    clear
    dialog --title "Nontaxable Combat Pay Election" \
    --nocancel \
    --inputbox "If you were a member of the U.S. Armed Forces who served in a combat zone, certain pay is excluded from your income. See Combat Zone Exclusion in Pub. 3. \n\nSee instructions to determine the amount." \
    11 80 2>$tempfile

    nontaxableCombat=`cat $tempfile`
    
    if [ $(isANumber $nontaxableCombat) -eq 0 ]; then
        determineNontaxCombat
    fi
}

# Item 39
# Set the addChildTaxCredit variable
function determineAdditionalChildTax () {
    clear
    dialog --title "Additional Child Tax Credit" \
    --nocancel \
    --inputbox "This credit is for certain people who have at least one qualifying child for the child tax credit (as defined in Steps 1, 2, and 3 of the instructions for line 6c). The additional child tax credit may give you a refund even if you do not owe any tax." \
    10 80 2>$tempfile

    addChildTaxCredit=`cat $tempfile`
    
    if [ $(isANumber $addChildTaxCredit) -eq 0 ]; then
        determineAdditionalChildTax
    fi
}

# item 40
# Set the americanOpportunity variable
function determineAmericanOpp () {
    clear
    dialog --title "American Opportunity Credit" \
    --nocancel \
    --inputbox "If you meet the requirements to claim an education credit (see the instructions for line 31), enter on this line the amount, if any, from Form 8863, line 8. To find out which education benefits you qualify for, go to www.irs.gov/uac/Am-I-Eligible-to-Claim-an-Education-Credit%3F" \
    10 80 2>$tempfile

    americanOpportunity=`cat $tempfile`
    
    if [ $(isANumber $americanOpportunity) -eq 0 ]; then
        determineAmericanOpp
    fi
}

# Verify the fifth section
function verifySectionFive () {
    dialog --backtitle "Verify" \
    --nocancel \
    --radiolist "Verify that the information is correct. When everything is correct, select continue." \
    13 70 18 \
    1 "Taxes withheld: $taxWithheld" off \
    2 "Paid from 2012: $paymentFrom2012" off \
    3 "Earned Income Credit: $EIC" off \
    4 "Non-taxable Combat Pay: $nontaxableCombat" off \
    5 "Additional Child Tax Credit: $addChildTaxCredit" off \
    6 "American Opportunity Credit: $americanOpportunity" off \
    7 "Continue" on \
    2>$tempfile
    
    selection=`cat $tempfile`

    exitStatus=1
    while [ ! $exitStatus -eq 0 ]; do
        case $selection in 
        1)
            determineWithheldTax
            verifySectionFive
            ;;
        2)
            determineAppliedChildTax
            verifySectionFive
            ;;
        3)
            determineEIC
            verifySectionFive
            ;;
        4)
            determineNontaxCombat
            verifySectionFive
            ;;
        5)
            determineAdditionalChildTax
            verifySectionFive
            ;;
        6)
            determineAmericanOpp
            verifySectionFive
            ;;
        7)
            exitStatus=0
            ;;
        *)
            verifySectionFive
            ;;
    esac
    done
}

# Item 41
# Accumulate total payments made toward taxes
function displayTotalPayments () {
    totalPayments=$(($taxWithheld+$paymentFrom2012+$EIC+$addChildTaxCredit+$americanOpportunity))

    dialog --title "Total Payments" \
    --msgbox "Your total payments are $totalPayments" \
    7 50
}

# Refund
# Item 42
# Calculate whether tax is owed or a refund is to be expected
function determineRefund () {
    if [ $totalPayments -gt $totalTax ]; then
        overpaid=$(($totalPayments-$totalTax))
        owe=0
    elif [ $totalPayments -lt $totalTax ]; then
        owe=$(($totalTax-$totalPayments))
        overpaid=0
    fi

    if [ $overpaid -gt $owe ]; then
        dialog --title "" \
        --msgbox "Congratulations. You overpaid by \$$overpaid." \
        7 40
    elif [ $owe -gt $overpaid ]; then
        dialog --title "" \
        --msgbox "Unfortunately you still owe \$$owe." \
        7 40
    fi
}
