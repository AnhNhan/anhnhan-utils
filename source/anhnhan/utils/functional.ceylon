/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

"Turns a function accepting two parameters into a function accepting an
 entry/pair. In other words:

     Return(Key, Item)

 gets transformed into

     Return(Key->Item)

 Use like this:

     Map<Key, Item> map = ...;
     // Normal
     map.map((Key->Item entry) => fun(entry.key, entry.item));
     // Cool
     map.map(acceptEntry(fun));"
shared Return acceptEntry<Return, Key, Item>(Callable<Return, [Key, Item]> callable)(Entry<Key, Item> entry)
    given Key satisfies Object
    => callable(entry.key, entry.item);

"Invokes all callables in a stream of void() functions."
shared void invokeAll({Callable<Anything, []>*} callables)
    => callables.collect((callable) => callable());
