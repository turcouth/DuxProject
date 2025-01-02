pragma circom 2.0.0;

template AgeCheck() {
    signal input minimumAge;
    signal input currentDate;
    signal private input inputBirthYear;
    signal private input inputBirthMonth;
    signal private input inputBirthDay;
    var birthYear = inputBirthYear;
    var birthMonth = inputBirthMonth;
    var birthDay = inputBirthDay;
    signal output isOldEnough;
    var currentYear = 1970 + (currentDate \ 31536000);
    var currentMonth = ((currentDate % 31536000) \ 2592000) + 1;
    var currentDay = ((currentDate % 2592000) \ 86400) + 1;
    var age = currentYear - birthYear;
    var monthNotReached = currentMonth < birthMonth ? 1 : 0;
    var sameMonthDayNotReached = (currentMonth == birthMonth && currentDay < birthDay) ? 1 : 0;
    age = age - (monthNotReached || sameMonthDayNotReached);
    isOldEnough <== age >= minimumAge ? 1 : 0;
}

component main = AgeCheck();