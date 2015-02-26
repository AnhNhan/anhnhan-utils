/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.test {
    test,
    assertEquals
}

shared alias Id => Integer;

shared alias Uid => String;
shared alias UidType => String;

"Extract the type of the given uid.

 E.g. DISQ-jiwef09ohir3f => DISQ"
shared UidType? uidType(Uid uid)
{
    value split = splitUid(uid);
    if (split.size > 1)
    {
        return split.first;
    }
    return null;
}

"Extract the sub-type of the given uid.

 E.g. DISQ-POST-f0jpo3nfg => POST"
shared UidType? uidSubType(Uid uid)
{
    value split = splitUid(uid);
    if (split.size > 2)
    {
        return split.rest.first;
    }
    return null;
}

{String*} splitUid(Uid uid) =>  uid.split('-'.equals);

// Tests

// Input -> [exp. output of uidType, exp. output of uidSubType]
{<Uid -> [UidType?, UidType?]>+} test_data = {
    "DISQ-jiwef09ohir3f" -> ["DISQ", null],
    "DISQ-POST-f0jpo3nfg" -> ["DISQ", "POST"],
    "DISQ-" -> ["DISQ", null],
    "f00" -> [null, null]
};

test
void uidTypeFuncsTest()
{
    for (input -> expected_values in test_data)
    {
        value expected_uidType = expected_values[0];
        value expected_uidSubType = expected_values[1];

        value result_uidType = uidType(input);
        value result_uidSubType = uidSubType(input);

        assertEquals(result_uidType, expected_uidType);
        assertEquals(result_uidSubType, expected_uidSubType);
    }
}
