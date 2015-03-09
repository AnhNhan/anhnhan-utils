/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.test {
    assertEquals,
    test
}

"Checks whether the given [[input]]is a value of the given type.

 Usefulness in filter applications is limited, since the resulting iterable will
 retain its original type."
shared see(`function pickOfType`)
Boolean ofType<Type>(Anything input)
        => input is Type;

"Filters out values of a given [[list|input]] that are not of [[Type]]."
shared
{Type*} pickOfType<Type>({Anything*} input)
        => {for (val in input) if (is Type val) val};

test
void testPickOfType()
{
    value list = {1, 2, 3.4, "foo", null, "bar"};

    value strings = pickOfType<String>(list);
    // assert (is {String*} strings);
    assertEquals(strings.sequence(), {"foo", "bar"}.sequence());

    value ints = pickOfType<Integer>(list);
    // assert (is {Integer*} ints);
    assertEquals(ints.sequence(), {1, 2}.sequence());
}

"Applies an operation on a value if it satisfies a given type. Otherwise we
 leave the value untouched.

 Useful for map operations."
shared
Return|Original maybeActOnType<Type, Return, Original>(Return transform(Type val))(Original val)
        given Type satisfies Object
{
    if (is Type val)
    {
        return transform(val);
    }
    return val;
}

shared
Return? actOnNullable<Type, Return>(Return transform(Type val))(Type? val)
        given Type satisfies Object
{
    if (exists val)
    {
        return transform(val);
    }
    return null;
}

"Casts a value to a given type, returning the value itself upon success and
 [[null]] on failure."
shared
Type? cast<Type>(Anything input)
{
    if (is Type input)
    {
        return input;
    }
    return null;
}

test
void testCast()
{
    assertEquals(cast<String>("foo"), "foo");
    assertEquals(cast<Integer>("foo"), null);

    assertEquals(cast<String>("foo")?.first, 'f');
    assertEquals(cast<Integer>("foo")?.positive, null);
}
