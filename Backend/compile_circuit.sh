#!/bin/bash
echo "pragma circom 2.0.0;" > age_check.circom
echo "" >> age_check.circom
echo "include \"../../../node_modules/circomlib/circuits/comparators.circom\";" >> age_check.circom
echo "" >> age_check.circom
echo "template AgeCheck() {" >> age_check.circom
echo "    signal input currentTimestamp;" >> age_check.circom
echo "    signal input minimumAge;" >> age_check.circom
echo "    signal input birthTimestamp;" >> age_check.circom
echo "    signal ageInSeconds <== currentTimestamp - birthTimestamp;" >> age_check.circom
echo "    signal minimumAgeInSeconds <== minimumAge * 31557600;" >> age_check.circom
echo "    component greaterOrEqual = GreaterEqThan(64);" >> age_check.circom
echo "    greaterOrEqual.in[0] <== ageInSeconds;" >> age_check.circom
echo "    greaterOrEqual.in[1] <== minimumAgeInSeconds;" >> age_check.circom
echo "    signal output isOldEnough <== greaterOrEqual.out;" >> age_check.circom
echo "}" >> age_check.circom
echo "" >> age_check.circom
echo "component main = AgeCheck();" >> age_check.circom
