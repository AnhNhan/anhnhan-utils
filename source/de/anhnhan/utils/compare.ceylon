/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.test {
    test,
    assertTrue,
    assertFalse
}
import ceylon.language.serialization {

    Element
}

"Since [[Null]] has no reasonably defined equality behavior (how do you declare
 that two absent values coming from wherever are equal), you cannot compare two
 nullable values directly. There are times where you _do_ want two nullable
 values to be comparable (since you defined null==null as true in that case),
 though. But in order to achieve this, that comes with a lot of boilerplate.

 You know what? Just use this function instead."
shared
Boolean nullableEquality<Element>(Element? el1, Element? el2)
{
    if (exists el1)
    {
        if (exists el2)
        {
            return el1 == el2;
        }
        else
        {
            return false;
        }
    }
    else
    {
        if (exists el2)
        {
            return false;
        }
        else
        {
            return true;
        }
    }
}

shared
Boolean nullableEquals<Element>(Element? el1, Element? el2)
{
    if (exists el1)
    {
        if (exists el2)
        {
            return el1.equals(el2);
        }
        else
        {
            return false;
        }
    }
    else
    {
        if (exists el2)
        {
            return false;
        }
        else
        {
            return true;
        }
    }
}

test
void testNullableEquality()
{
    assertTrue(nullableEquality(null, null));
    assertTrue(nullableEquality("foo", "foo"));

    assertFalse(nullableEquality(null, "foo"));
    assertFalse(nullableEquality("foo", null));
    assertFalse(nullableEquality("foo", "bar"));
}
