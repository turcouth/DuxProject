pragma circom 2.0.0;

include "../../../node_modules/circomlib/circuits/comparators.circom";

template AgeCheck() {
    signal input currentTimestamp;
    signal input minimumAge;
    signal input birthTimestamp;
    signal ageInSeconds <== currentTimestamp - birthTimestamp;
    signal minimumAgeInSeconds <== minimumAge * 31557600;
    component greaterOrEqual = GreaterEqThan(64);
    greaterOrEqual.in[0] <== ageInSeconds;
    greaterOrEqual.in[1] <== minimumAgeInSeconds;
    signal output isOldEnough <== greaterOrEqual.out;
}

component main = AgeCheck();
