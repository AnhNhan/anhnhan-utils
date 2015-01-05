/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
View<Pixel> warp<Pixel>([Integer, Integer]?(Integer, Integer) warp, Integer? nW = null, Integer? nH = null)(View<Pixel> originalView)
        given Pixel satisfies Object
{
    object warped
            satisfies View<Pixel>
    {
        shared actual Integer height = nH else originalView.height;

        shared actual Integer width = nW else originalView.width;

        shared actual Pixel? get([Integer, Integer] key){
            if (exists newKey = warp(*key))
            {
                return originalView.get(newKey);
            }
            else
            {
                return null;
            }
        }
    }

    return warped;
}
