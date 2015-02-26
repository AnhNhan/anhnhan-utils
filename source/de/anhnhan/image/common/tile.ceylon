/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
View<Pixel> tile<Pixel>(View<Pixel> src)
        given Pixel satisfies Object
{
    return warp<Pixel>((x, y) => [x.remainder(src.width), y.remainder(src.height)])(src);
}
