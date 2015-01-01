/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared alias Ok<ParsedLiteral, InputRest>
    given ParsedLiteral satisfies Object
    => [ParsedLiteral, InputRest];

"Denotes a failed parse attempt."
shared interface Failure
    of failure
{}

shared object failure satisfies Failure {}

"Denotes either a successful parse attempt (yielding [[Ok]]), or a [[Failable]] upon failure."
shared alias MaybeLiteral<ParsedLiteral, InputRest>
    given ParsedLiteral satisfies Object
    => Ok<ParsedLiteral, InputRest>|Failure;
