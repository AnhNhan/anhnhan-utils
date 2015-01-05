/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
View<Other> colorMap<Pixel, Other>(Other(Pixel) fun)(View<Pixel> src)
        given Pixel satisfies Object
        given Other satisfies Object
{
    object mapped satisfies View<Other>
    {
        shared actual Other? get([Integer, Integer] key)
        {
            if (exists pix = src.get(key))
            {
                return fun(pix);
            }
            else
            {
                return null;
            }
        }

        shared actual Integer height = src.height;

        shared actual Integer width = src.width;
    }

    return mapped;
}