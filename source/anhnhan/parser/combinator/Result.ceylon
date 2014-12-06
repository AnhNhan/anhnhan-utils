/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared alias LiteralResult<Literal, InputRest>
    given Literal satisfies Object
    => [Literal, InputRest];

"Denotes a failed parse attempt."
shared interface Failure
    of failure {}

shared object failure satisfies Failure {}

"Denotes either a successful parse attempt (yielding [[T]]), or a [[Failable]] upon failure."
shared alias Failable<T> => T|Failure;

"Denotes either a successful parse attempt (yielding [[LiteralResult]]), or a [[Failable]] upon failure."
shared alias MaybeLiteral<Literal, InputRest>
    given Literal satisfies Object
    => Failable<LiteralResult<Literal, InputRest>>;

"Indicates whether a parse attempt was successful."
shared Boolean successful<T>(Failable<T> input)
{
    return input is T;
}
