/**
    SupplyRunner Source Code

    Not disclosed to public
    share with anhnhan@outlook.com in case of violation
 */

import ceylon.test {
    test,
    assertEquals,
    assertFalse,
    assertTrue
}

// Not sure if bloom filters make sense on JVM/JS given their
// mediocre close-to-memory property, but hey, they're magic!
//
// Also, consider using `Integer`s instead. As in, do the benchmarcks
// at some point in the future.

"Excerpt from Wikipedia:

     A [Bloom filter][1] is a space-efficient probabilistic data structure,
     conceived by Burton Howard Bloom in 1970, that is used to test whether an
     element is a member of a set. False positive matches are possible, but
     false negatives are not; i.e. a query returns either \"possibly in set\" or
     \"definitely not in set\". Elements can be added to the set, but not removed
     (though this can be addressed with a \"counting\" filter). The more elements
     that are added to the set, the larger the probability of false positives.

     [1]: http://en.wikipedia.org/wiki/Bloom_filter

 More info for bloom filters and the workings of their magic:

     http://www.michaelnielsen.org/ddi/why-bloom-filters-work-the-way-they-do/
"
shared class BloomFilter<Key, Hash_t>(size, hash_functions)
    satisfies Category<Key>
    given Key satisfies Object
    given Hash_t satisfies Integer
{
    shared Integer size;
    shared Integer bit_size = size * 8;
    variable Array<Byte> buffer = arrayOfSize<Byte>(size, 0.byte);

    Hash_t(Key)+ hash_functions;

    Integer byte_offset(Hash_t x) => (x / 8) % buffer.size;

    Integer bit_offset(Hash_t x) => x % 8;

    Boolean check_offset(Hash_t hash)
    {
        return buffer[byte_offset(hash)]?.get(bit_offset(hash)) else false;
    }

    "Tests whether an element is maybe in the set. If it returns false,
     we can guarantee that it is not in the set."
    shared actual Boolean contains(Key key)
    {
        for (fun in hash_functions)
        {
            // If any of the bits at offsets indicated by the hash functions
            // are zero, we can be sure that the key is not in the set.
            if (!check_offset(fun(key)))
            {
                return false;
            }
        }

        // All one's. It's maybe in the set.
        return true;
    }

    "Adds an element to the set."
    shared void add(Key key)
    {
        // Set all bits at offsets indicated by the hash functions to 1.
        for (fun in hash_functions)
        {
            value hash = fun(key);
            value offset = byte_offset(hash);
            buffer.set(offset, buffer[offset]?.set(bit_offset(hash)) else buffer[offset] else 0.byte);
        }
    }

    shared void clear()
    {
        buffer = arrayOfSize<Byte>(size, 0.byte);
    }

    shared actual String string
    {
        variable String s = "0b";

        for (byte in buffer)
        {
            for (nn in 7..0)
            {
                s += byte.get(nn) then "1" else "0";
            }
        }

        return s;
    }
}

test
void testBloomFilter()
{
    value b1 = BloomFilter(5, String.hash, (String key) => (key.hash * 31) + 7);

    assertEquals(b1.size, 5);
    assertEquals(b1.bit_size, 40);

    // print(b1);
    assertFalse("foo" in b1);
    b1.add("foo");
    assertTrue("foo" in b1);

    // print(b1);
    assertFalse("bar" in b1);
    b1.add("bar");
    assertTrue("bar" in b1);

    // print(b1);
    assertFalse("baz" in b1);
    b1.add("baz");
    assertTrue("baz" in b1);

    // print(b1);
    b1.clear();
    assertFalse("foo" in b1);
    assertFalse("bar" in b1);
    assertFalse("baz" in b1);
}
