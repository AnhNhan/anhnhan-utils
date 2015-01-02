/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

CharacterPredicate isUpper = Character.uppercase;
CharacterPredicate isLower = Character.lowercase;
CharacterPredicate isLetter = Character.letter;

CharacterPredicate isAsciiUpper = (Character char) => char in 'A'..'Z';
CharacterPredicate isAsciiLower = (Character char) => char in 'a'..'z';
CharacterPredicate isAsciiLetter = (Character char) => isAsciiLower(char) || isAsciiUpper(char);

CharacterPredicate isDigit = (Character char) => char in '0'..'9';
CharacterPredicate isHex = (Character char) => isDigit(char) || char in 'a'..'f' || char in 'A'..'F';
