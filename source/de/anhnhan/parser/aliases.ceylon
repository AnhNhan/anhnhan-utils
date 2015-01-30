/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
interface Characters<Absent = Null>
        given Absent satisfies Null
        => Iterable<Character, Absent>;
