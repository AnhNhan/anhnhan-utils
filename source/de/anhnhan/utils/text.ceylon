/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

/*
import ceylon.collection {
   HashSet,
   LinkedList
}
import ceylon.test {
   assertEquals,
   test
}

shared
String wrapText(String string, Integer length, String terminator = "\n")
{
    if (string.size <= length)
    {
        return string;
    }

    // These are incomplete
    // Covers most of Ascii only

    value breakChars = HashSet
    {
        ' ', '\n', ';', ':', '[', '(', ',', '_'
    };
    value stopChars = HashSet
    {
        '.', '!', '?'
    };

    variable
    value str = string;
    value lines = LinkedList<String>();
    value termArea = length - min({length, terminator.size});

    while (!str.empty)
    {
        value line = str[0:length];
        variable
        Integer? wordBoundary = null;
        variable
        Integer? stopBoundary = null;

        for (ii->char in line.reversed.indexed)
        {
            if (char in breakChars, ii <= termArea)
            {
                wordBoundary = ii;
            }
            else if (char in stopChars, ii < length)
            {
                stopBoundary = ii + 1;
                break;
            }
            else if (exists _ = wordBoundary)
            {
                break;
            }
        }

        if (exists _stopBoundary = stopBoundary)
        {
            lines.add(str[0:_stopBoundary] + "\n");
            str = String(str.sublistFrom(_stopBoundary));
            continue;
        }

        value __wordBoundary = wordBoundary;
        switch (__wordBoundary)
        case (is Null)
        { wordBoundary = termArea; }
        case (0)
        { wordBoundary = termArea; }
        else
        {}
        assert(exists _wordBoundary = wordBoundary);

        lines.add(str[0:_wordBoundary] + "\n");
        str = String(str.sublistFrom(_wordBoundary));
    }

    return lines.fold("")(plus<String>);
}

test
void testWrapText()
{
    assertEquals(wrapText("aaaaa", 5), "aaaaa");
    assertEquals(wrapText("aaaaaa", 5), "aaaaa\na");
    assertEquals(wrapText("aaa.aaa", 5), "aaa.\naaa");
}
*/

shared
{String*}(String)(Boolean(Character)=, Boolean=, Boolean=) splitStringBy
        = swapCurried(String.split);
