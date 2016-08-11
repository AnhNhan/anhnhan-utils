/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import de.anhnhan.image.common {
    View,
    nearestNeighbor,
    RGB
}

import ceylon.test {
    assertEquals,
    test,
    assertTrue
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

    value colorField = Array.ofSize(comp_width * comp_height, 0);
    value hashField = Array.ofSize((comp_width - 1) * comp_height, false);
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

test
void testXor()
{
    value val1 = {false, false, true, false, false};
    value val2 = {false, true, false, false, false};
    value val3 = {false, true, false, true, false};

    assertEquals(dhash_xor(val1, val1), 0);
    assertEquals(dhash_xor(val1, val2), 2);
    assertEquals(dhash_xor(val2, val1), 2);
    assertEquals(dhash_xor(val1, val3), 3);
    assertEquals(dhash_xor(val3, val1), 3);
    assertEquals(dhash_xor(val2, val3), 1);
    assertEquals(dhash_xor(val3, val2), 1);
}

shared
[[Boolean+]+] dhash_variants({Boolean*} _orig, Integer max_distance)
{
    assert(max_distance >= 0);
    assert(nonempty orig = _orig.sequence());
    if (max_distance == 0)
    {
        return [orig];
    }

    value dist1s = [for (index->bit in orig.indexed)
        [!bit]
            .prepend(index == 0 then [] else orig[0..index-1])
            .append(orig.sublistFrom(index+1).sequence())
    ];

    return [for (d1 in dist1s.append([orig])) dhash_variants(d1, max_distance - 1)]
        .reduce(([[Boolean+]+] partial, [[Boolean+]+] element) => partial.append(element));
}

test
void testVariants()
{
    value val1 = [false, true, false];
    value set1_d1 = [
        [false, true, false],
        [true, true, false],
        [false, true, true],
        [false, false, false]
    ];

    value d1 = dhash_variants(val1, 1);
    assertTrue(d1.every((element) => element in set1_d1));
    assertTrue(set1_d1.every((element) => element in d1));

    value set1_d2 = [
        [false, true, false],
        [true, true, false],
        [false, true, true],
        [false, false, false],
        [false, false, true],
        [true, true, true],
        [true, false, false]
    ];
    value d2 = dhash_variants(val1, 2);
    assertTrue(d2.every((element) => element in set1_d2));
    assertTrue(set1_d2.every((element) => element in d2));
}
