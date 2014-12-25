/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.time {
    DateTime
}

shared interface Entity
{
    field { type = sql_datetime; }
    shared formal DateTime createdAt;
    field { type = sql_datetime; }
    shared formal DateTime modifiedAt;
}

shared interface SpeciallyMutableEntity
{
    shared formal void setValue<in Value>(String name, Value val);
}
