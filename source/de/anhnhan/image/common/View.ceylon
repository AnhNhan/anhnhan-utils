/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
interface View<Element>
        satisfies Correspondence<[Integer, Integer], Element> // & {{Element*}*}
        given Element satisfies Object
{
    "Aka the number of lines in this view."
    shared formal
    Integer height;

    shared formal
    Integer width;

    shared formal actual
    Element? get([Integer, Integer] key);

    shared actual default
    Boolean defines([Integer, Integer] key) => get(key) exists;
}

shared
interface DirectView<Element>
        satisfies View<Element> & {Scanline<Element>*}
        given Element satisfies Object
{
    shared formal
    Scanline<Element> line(Integer line);

    shared default actual
    Iterator<Scanline<Element>> iterator()
            => {for (hh in 0..height-1) line(hh)}.iterator();

    shared actual default
    Element? get([Integer, Integer] key)
            => line(key[0])[key[1]];
}

shared
interface Scanline<Element>
        satisfies {Element*} & Ranged<Integer, Element, Scanline<Element>> & Correspondence<Integer, Element>
        given Element satisfies Object
{
    shared formal
    Integer width;

    shared formal actual
    Element get(Integer index);

    shared default actual
    Iterator<Element> iterator()
            => {for (ww in 0..width-1) get(ww)}.iterator();
}

shared
interface MutableView<Element>
        satisfies View<Element> & ViewMutator<Element>
        given Element satisfies Object
{}

shared
interface ViewMutator<in Element>
{
    shared formal
    void put([Integer, Integer] index, Element element);
}
