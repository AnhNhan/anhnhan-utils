/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

CharacterPredicate isUpper = Character.uppercase;
CharacterPredicate isLower = Character.lowercase;
CharacterPredicate isLetter = Character.letter;

CharacterPredicate isAsciiUpper = ('A'..'Z').contains;
CharacterPredicate isAsciiLower = ('a'..'z').contains;
CharacterPredicate isAsciiLetter = or(isAsciiLower, isAsciiUpper);

CharacterPredicate isDigit = ('0'..'9').contains;
CharacterPredicate isHex = or(isDigit, or(('a'..'f').contains, ('A'..'F').contains));

CharacterPredicate isLetterOrDigit = or(isLetter, isDigit);
