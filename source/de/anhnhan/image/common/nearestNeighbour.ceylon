/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.test {
    test,
    assertEquals
}

shared
View<Pixel> nearestNeighbor<Pixel>(Integer newWidth, Integer newHeight)(View<Pixel> src)
        given Pixel satisfies Object
        => warp<Pixel>((x, y) => [x * src.width / newWidth, y * src.height / newHeight], newWidth, newHeight)(src);

test
void testNearestNeighbor()
{
    value g = procedural((x, y) => x+10*y)(10, 10);
    value n = nearestNeighbor<Integer>(100, 100)(g);
    assertEquals(n[[12, 34]], 31);
}
