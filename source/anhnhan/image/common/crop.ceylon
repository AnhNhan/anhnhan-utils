/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
View<Pixel> crop<Pixel>(Integer x0, Integer y0, Integer x1, Integer y1)(View<Pixel> origView)
        given Pixel satisfies Object
{
    assert( 0 <=    x0 &&  0 <=    y0);
    assert(x0 <     x1 && y0 <     y1);
    assert(x1 <= origView.width && y1 <= origView.height);

    value width = x1 - x0;
    value height = y1 - y0;
    return warp<Pixel>((x, y) => (x < width && y < height) then [x + x0, y + y0])(origView);
}