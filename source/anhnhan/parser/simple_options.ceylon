/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.parser.parsec {
    PointOutTheError
}

import ceylon.collection {
    HashMap
}
import ceylon.test {
    test
}

"""Parses a flat options string into a dictionary.

       value dict = simple_options("location=United Kingdom, language=British English, alive");
       assert(is Map<String, String|[]> dict);
       assert(exists location = dict["location"]);
       assert(exists language = dict["language"]);
       assert(is Empty alive = dict["alive"]);
 """
shared
Map<String, String|[]>|PointOutTheError<Character, Character> simple_options(String input, Boolean case_sensitive = false, Character separator = ',', Character assignment = '=', Boolean trim = true)
{
    value parts = input.split(separator.equals);
    value dict = HashMap<String, String|[]>();

    for (index->part in parts.indexed)
    {
        value _part = trim then part.trim(Character.whitespace) else part;
        switch (_part.count(assignment.equals))
        case (0)
        {
            dict.put(_part, []);
        }
        case (1)
        {
            assert(nonempty split = _part.split(assignment.equals).sequence());
            value key = split[0];
            value val = split[1];
            if (exists val)
            {
                dict.put(
                    trim then key.trim(Character.whitespace) else key,
                    trim then val.trim(Character.whitespace) else val
                );
            }
            else
            {
                return PointOutTheError(parts.take(index).fold("")(plus<String>) + key + String({assignment}), parts.skip(index).fold("")(plus<String>));
            }
        }
        else
        {
            return PointOutTheError(parts.take(index).fold("")(plus<String>), parts.skip(index).fold("")(plus<String>));
        }
    }

    return dict;
}

test
void testSimpleOptions()
{
    value dict = simple_options("location=United Kingdom, language=British English, alive");
    assert(is Map<String, String|[]> dict);
    assert(exists location = dict["location"]);
    assert(exists language = dict["language"]);
    assert(is Empty alive = dict["alive"]);
}
