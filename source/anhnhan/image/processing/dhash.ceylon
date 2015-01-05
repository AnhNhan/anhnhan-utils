/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.image.common {
    View,
    nearestNeighbor,
    RGB
}

shared
{Boolean*} dhash<Pixel, Image = View<Pixel>>(
    Integer(Pixel) convertToLuminosity,
    Image(Image, Integer, Integer) downscale,
    Integer comp_width = 9,
    Integer comp_height = 8
)(Image src)
        given Pixel satisfies Object
        given Image satisfies View<Pixel>
{
    value view = downscale(src, comp_width, comp_height);

    value colorField = arrayOfSize(comp_width * comp_height, 0);
    value hashField = arrayOfSize((comp_width - 1) * comp_height, false);
    variable
    value ii = 0;

    for (w in 0..view.width-1)
    {
        for (h in 0..view.height-1)
        {
            value pos = w * (comp_width - 1) + h;
            assert(exists pixel = view[[w, h]]);
            value c = convertToLuminosity(pixel);
            colorField.set(pos, c);
            if (w != 0)
            {
                // I think this compares by columns?
                assert(exists curr = colorField[pos], exists prev = colorField[pos - 1]);
                hashField.set(ii++, curr > prev);
            }
        }
    }

    return hashField;
}

shared
{Boolean*} dhash_rgb_nearest<Image>(Image img)
        given Image satisfies View<RGB>
        => dhash((RGB pixel) => pixel.greyscale.r, uncurry((View<RGB> src) => (Integer w, Integer h) => nearestNeighbor<RGB>(w, h)(src)), 9, 8)(img);

shared
String dhash_to_string({Boolean*} input)
        => String(input.map((bool) => bool then '1' else '0'));

shared
Integer dhash_xor({Boolean*} _this, {Boolean*} _that)
{
    assert(_this.size == _that.size);
    if (_this.empty)
    {
        return 0;
    }

    variable
    value differences = 0;

    for (index->_this_bit in _this.indexed)
    {
        value _that_bit = _that.getFromFirst(index) else nothing;

        if (_this_bit == _that_bit)
        {
            continue;
        }

        differences++;
    }

    return differences;
}
