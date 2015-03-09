/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.test {
    test
}

test
void test_diff_trees_1()
{
    value tree1 = SList { "foo", "bar", "baz" };
    value tree2 = SList { "foo", "baz", "hello" };
}
