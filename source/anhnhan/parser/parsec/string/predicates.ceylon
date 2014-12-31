/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

Boolean(Character) isUpper = Character.uppercase;
Boolean(Character) isLower = Character.lowercase;
Boolean(Character) isLetter = Character.letter;

Boolean(Character) isAsciiUpper = (Character char) => char in 'A'..'Z';
Boolean(Character) isAsciiLower = (Character char) => char in 'a'..'z';
Boolean(Character) isAsciiLetter = (Character char) => isAsciiLower(char) || isAsciiUpper(char);

Boolean(Character) isDigit = (Character char) => char in '0'..'9';
Boolean(Character) isHex = (Character char) => isDigit(char) || char in 'a'..'f' || char in 'A'..'F';
