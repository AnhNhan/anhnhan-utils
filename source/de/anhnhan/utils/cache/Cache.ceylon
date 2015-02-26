/**
    SupplyRunner Source Code

    Not disclosed to public
    share with anhnhan@outlook.com in case of violation
 */

"Common interface for cache operations."
shared interface Cache<ObjectType, in Key>
    satisfies Category<Key> & Correspondence<Key, ObjectType>
    given Key satisfies Object
{
    shared actual formal ObjectType? get(Key key);

    "Standard implementation for [[Cache.contains]]. May be inperformant, since
     it calls [[Cache.get]], so the full object is loaded and dismissed for
     each call."
    shared actual default Boolean contains(Key key) => get(key) exists;

    shared actual Boolean defines(Key key) => contains(key);

    shared formal Boolean put(Key key, ObjectType item, Integer lifetime = 0);

    shared formal Boolean delete(Key key);
}
