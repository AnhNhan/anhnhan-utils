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

shared Key->Return onItem<Key, Item, Return>(Return transform(Item item))(Key->Item entry)
    given Key satisfies Object
    => entry.key->transform(entry.item);

shared Return->Item onKey<Key, Item, Return>(Return transform(Key item))(Key->Item entry)
    given Key satisfies Object
    given Return satisfies Object
    => transform(entry.key)->entry.item;

"Invokes all callables in a stream of void() functions."
shared void invokeAll({Callable<Anything, []>*} callables)
    => callables.collect((callable) => callable());

"Creates a pipe function that *pipes* a set of its arguments through the two
 given functions.

     value chars = {65, 66, 67};
     chars.collect(pipe2(2.plus, Integer.character));

 produces the output

     C
     D
     E

 while the following code is equivalent, but a little bit less beautiful

     chars.map(2.plus).collect(Integer.character);"
shared Callable<Return, Args> pipe2<Return, Between, Args>(Callable<Between, Args> first, Callable<Return, [Between]> second)
        given Args satisfies Anything[]
        => flatten((Args args) => second(first(*args)));

"Swaps two parameter sets for a given curried (or factorizing) function. This
 will sometimes save you writing an embedded function, resulting in cleaner
 code.

     {String*}(String)(Boolean(Character)=, Boolean=, Boolean=) splitStringBy
             = swapCurried(String.split);
     value strings = {\"foo-bar\", \"bar-baz\"};
     value result = strings.collect(splitStringBy('-'.equals));

     // Otherwise
     value result = strings.collect((str) => str.split('-'.equals));
     "
shared Callable<Callable<Return, Arg1>, Arg2> swapCurried<Return, Arg1, Arg2>(Callable<Callable<Return, Arg2>, Arg1> fun)
        given Arg1 satisfies Anything[]
        given Arg2 satisfies Anything[]
        => flatten((Arg2 arg2) => flatten((Arg1 arg1) => fun(*arg1)(*arg2)));
