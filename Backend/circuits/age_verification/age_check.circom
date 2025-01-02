pragma circom 2.0.0;

template AgeCheck() {
    signal input birthTimestamp;   // Entrée privée : Timestamp de la date de naissance
    signal input currentTimestamp; // Entrée publique : Timestamp actuel
    signal input minAgeInSeconds;  // Entrée publique : Âge minimum requis en secondes
    signal output isAdult;         // Sortie publique : 1 si majeur, 0 sinon

    signal ageInSeconds;
    signal leapYears;
    signal startYear;
    signal endYear;
    signal diff;

    // Conversion des timestamps en années
    startYear <== birthTimestamp / (365 * 24 * 60 * 60);
    endYear <== currentTimestamp / (365 * 24 * 60 * 60);

    // Calcul des années bissextiles
    leapYears <== (endYear / 4 - endYear / 100 + endYear / 400) -
                  (startYear / 4 - startYear / 100 + startYear / 400);

    // Calcul de l'âge en secondes
    ageInSeconds <== currentTimestamp - birthTimestamp + (leapYears * 24 * 60 * 60);

    // Calcul de la différence entre l'âge et le minimum requis
    diff <== ageInSeconds - minAgeInSeconds;

    // Déterminer si la personne est majeure
    isAdult <-- diff >= 0 ? 1 : 0;
    
    // Contrainte pour s'assurer que isAdult est binaire
    isAdult * (isAdult - 1) === 0;
}

component main {public [currentTimestamp, minAgeInSeconds]} = AgeCheck();

