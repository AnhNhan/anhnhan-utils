/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.test {
    assertEquals,
    test
}

shared
View<Pixel> procedural<Pixel>(Pixel(Integer, Integer) formula)(Integer _width, Integer _height)
        given Pixel satisfies Object
{
    object procedural
            satisfies View<Pixel>
    {
        shared actual Pixel? get([Integer, Integer] key) => key[0] < _width && key[1] < _height then formula(*key);

        shared actual Integer height = _height;

        shared actual Integer width = _width;

    }

    return procedural;
}

shared
View<Pixel> solid<Pixel>(Pixel pixel)(Integer width, Integer height)
        given Pixel satisfies Object
        => procedural((Integer _1, Integer _2) => pixel)(width, height);

test
void testSfn4i()
{
    assertEquals(solid(42)(1, 1)[[0, 0]], 42);
}
