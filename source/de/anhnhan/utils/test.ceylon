/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.test {
    test
}

"Asserts that an [[AssertionError]] has been thrown (like when an `assert` failed)."
shared
void assertHasAssertionError<CB, Args>(CB callable)
        given Args satisfies Anything[]
        given CB satisfies Callable<Anything, Args>
        => flatten(void (Args args)
            {
                try
                {
                    callable(*args);
                    "Did not throw AssertionError!"
                    assert (false);
                }
                catch (AssertionError err)
                {
                    // <nothing>
                    // success
                }
            });

test
void testAssertHasAssertionError()
{
    try
    {
        assertHasAssertionError(void () { assert(false); });
        assert (false);
    }
    catch (AssertionError err)
    {
        // success
    }

    try
    {
        assertHasAssertionError(void () { assert(true); });
        // success
    }
    catch (AssertionError err)
    {
        assert (false);
    }
}
