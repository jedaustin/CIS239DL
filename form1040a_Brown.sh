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

source form1040aFunctions.sh

# Method calls start here

determineName
determineSocial
determineAddress
verifySectionOne

determineFilingStatus
determineExemptions
determineIncome

determineTaxableInterest
determineTaxExemptInterest
determineOrdinaryDividends
determineQualifiedDividends
determineCapitalGain
determineIRADistributions
determineTaxableIRADistributions
determinePensions
determineTaxablePensions
determineUnemployment
determineSocSec
determineTaxableSocSec
verifySectionTwo

displayTaxableIncome

determineEducatorExpenses
determineIRADeductions
determineStudentLoanInterestDeductions
determineTuitionAndFees
verifySectionThree

displayTotalAdjustments
ensureNonItemized 

twentyThreeA

displayStandardDeduction
displayExemptionsCredits
determineTaxes

determineChildCareCredit
determineElderlyCredit
determineEducationCredit
determineRetirementCredit
determineChildTaxCredit
verifySectionFour

displayTotalCredits
displayAdjustedTax

determineWithheldTax
determineAppliedTax
determineEIC
determineNontaxCombat
determineAdditionalChildTax
determineAmericanOpp
verifySectionFive

displayTotalPayments

determineRefund
