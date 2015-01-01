/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

"Returns the identity of the passed value.

 In most languages and environments, this just returns the value itself.

 Useful as a stub function for monoid-like systems, to denote that nothing
 should be done to the value.

     coll.map(id) == coll

 Also useful in PHP 5.3 and below to circumvent an error in the grammar that
 prevents us from chaining method calls onto object constructor calls.

     id(new \\IstdClass)->foo()
 "
shared T id<T>(T val)
    => val;

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

"Uncurries a given function of two curried arguments.

     // Bothersome
     value map = TreeMap<String, ...>((String first, String second) => first.compare(second));
     // Cool
     value map = TreeMap<String, ...>(uncurry(String.compare));"
shared Return uncurry<Return, First, Second>(Return(Second)(First) fun)(First first, Second second)
    => fun(first)(second);

"Invokes all callables in a stream of void() functions."
shared void invokeAll({Callable<Anything, []>*} callables)
    => callables.collect((callable) => callable());
