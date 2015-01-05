import ceylon.test {
    test
}
/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

// Diagonal
shared
View<Pixel> flipXY<Pixel>(View<Pixel> src)
        given Pixel satisfies Object
        => warp<Pixel>((x, y) => [y, x])(src);

"Flips a view horizontally."
shared
View<Pixel> flipX<Pixel>(View<Pixel> src)
        given Pixel satisfies Object
        => warp<Pixel>((x, y) => [src.width-x-1, y])(src);

"Flips a view vertically."
shared
View<Pixel> flipY<Pixel>(View<Pixel> src)
        given Pixel satisfies Object
        => warp<Pixel>((x, y) => [x, src.height-y-1])(src);

// Inverted coordinates
shared
View<Pixel> flip<Pixel>(View<Pixel> src)
        given Pixel satisfies Object
        => flipX(flipY(src));

shared
View<Pixel> rotateCW<Pixel>(View<Pixel> src)
        given Pixel satisfies Object
        => flipX(flipXY(src));

shared
View<Pixel> rotateCCW<Pixel>(View<Pixel> src)
        given Pixel satisfies Object
        => flipY(flipXY(src));

test
void testFlips()
{
    value g = procedural((x, y) => x+10*y)(10, 10);
    function corners<El>(View<El> v) given El satisfies Object { return [v[[0, 0]], v[[9, 0]], v[[0, 9]], v[[9, 9]]]; }
    assert(corners(g           ) == [ 0,  9, 90, 99]);
    assert(corners(flipXY(g)   ) == [ 0, 90,  9, 99]);
    assert(corners(rotateCW(g) ) == [90,  0, 99,  9]);
    assert(corners(rotateCCW(g)) == [ 9, 99,  0, 90]);
}
