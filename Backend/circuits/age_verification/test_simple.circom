pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";

template AgeCheck() {
    // Public inputs
    signal input minimumAge;
    signal input currentDate;
    
    // Private input
    signal input inputBirthYear;
    
    // Output
    signal output isOldEnough;
    
    // Calculation
    var age = 1970 + (currentDate \ 31536000) - inputBirthYear;
    
    // Comparison using circomlib
    component ageCheck = GreaterEqThan(32);  // 32 bits for age comparison
    ageCheck.in[0] <== age;
    ageCheck.in[1] <== minimumAge;
    isOldEnough <== ageCheck.out;
}

component main {public [minimumAge, currentDate]} = AgeCheck();