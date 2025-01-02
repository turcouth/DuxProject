pragma circom 2.0.0;

template AgeCheck() {
    signal input birthTimestamp;
    signal input currentTimestamp;
    signal input minAgeInSeconds;
    signal output isAdult;

    signal ageInSeconds;
    signal leapYears;
    signal startYear;
    signal endYear;
    signal diff;
    signal isPositive;

    startYear <== birthTimestamp / (365 * 24 * 60 * 60);
    endYear <== currentTimestamp / (365 * 24 * 60 * 60);

    leapYears <== (endYear / 4 - endYear / 100 + endYear / 400) -
                  (startYear / 4 - startYear / 100 + startYear / 400);

    ageInSeconds <== currentTimestamp - birthTimestamp + (leapYears * 24 * 60 * 60);
    diff <== ageInSeconds - minAgeInSeconds;
    isPositive <-- diff >= 0 ? 1 : 0;
    isPositive * (isPositive - 1) === 0;
    diff * (1 - isPositive) === 0;
    isAdult <== isPositive;
}

component main = AgeCheck();