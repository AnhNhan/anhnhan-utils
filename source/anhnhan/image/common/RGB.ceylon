import ceylon.test {
    assertEquals,
    test
}
/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
class RGB(r = 0, g = 0, b = 0)
{
    shared
    Integer r;

    shared
    Integer g;

    shared
    Integer b;

    shared
    RGB greyscale
    {
        value c = (r + g + b) / 3;
        return RGB(c, c, c);
    }

    shared
    Boolean isGreyscale
            = r == g && g == b;
}

shared
RGB rgbFromInteger(Integer int)
{
    return RGB(int.and(#FF0000), int.and(#00FF00), int.and(#0000FF));
}

test
void testRgbFromInteger()
{
    value input1 = #ABCDEF;
    value color1 = rgbFromInteger(input1);

    assertEquals(color1.r, #AB);
    assertEquals(color1.g, #CD);
    assertEquals(color1.b, #EF);
}
