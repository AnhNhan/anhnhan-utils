/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared alias LiteralResult<Literal, Rest>
    given Literal satisfies Object
    => [Literal, Rest];

"Denotes a failed parse attempt."
shared interface Failure
    of failure {}

shared object failure satisfies Failure {}

"Denotes either a successful parse attempt (yielding [[T]]), or a [[Failable]]."
shared alias Failable<T> => T|Failure;

"Denotes either a successful parse attempt (yielding [[LiteralResult]]), or a [[Failable]]."
shared alias MaybeLiteral<Literal, Rest>
    given Literal satisfies Object
    => Failable<LiteralResult<Literal, Rest>>;

"Indicates whether a parse attempt was successful."
shared Boolean successful<T>(Failable<T> input)
{
    return input is T;
}
