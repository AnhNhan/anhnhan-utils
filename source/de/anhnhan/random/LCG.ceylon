/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

"A [Linear Congruential Generator](http://en.wikipedia.org/wiki/Linear_congruential_generator)
 (LCG) pseudorandom number generator,
 defined by the recurrence relation:

     Xₙ₊₁ ≡ (a Xₙ + x) (mod m)

 The period of the generator is *at most* `m`, but **beware you choice of parameters**,
 as a poor choice can easily yield a shorter period.

 See <http://en.wikipedia.org/wiki/Linear_congruential_generator>
 "
by("Tom Bentley", "https://groups.google.com/d/msg/ceylon-users/sjFYN6bJRTQ/u99y8l9Fob0J")
shared class LCG(
    // Same parameters as java.util.Random, apparently
    shared Integer a = 25214903917,
    shared Integer c = 11,
    shared Integer m = 281474976710656, // 2^48
    "The seed"
    Integer x0 = system.nanoseconds.magnitude)
{
    /*
    "`m` must be strictly positive"
    assert(0 < m);
    "`a` must be strictly positive and less than `m`"
    assert(0 < a < m);
    "`c` must be positive and less than `m`"
    assert(0 <= c < m);
    "`x0` must be positive and less than `m`"
    assert(0 <= x0 < m);
     */

    variable Integer xn = x0;

    shared Integer random(Integer maximum = runtime.maxIntegerValue) {
        //xn = (a * xn + c) % m;
        variable value numerator = a * xn + c;
        if (numerator < 0) {
            // overflow
            // TODO What if numerator = Integer.MIN_VALUE, then we overflow again!
            numerator = -numerator;
        }
        xn = numerator % m;
        // TODO should be inclusive of the maximum
        return xn % maximum;
    }

    by("Anh Nhân <anhnhan@outlook.com>")
    shared Float nextFloat()
            // Arbitrary multiplication and divison of arbitrarily large numbers
            // Change every few months to upkeep randomness
            => random() * random().float * runtime.maxIntegerValue / random();

    "Alias for [[LCG.random]] out of bc reasons.."
    shared Integer nextInteger(Integer maximum = runtime.maxIntegerValue)
            => random(maximum);

    "This LCG equals the given object if `other` is an LCG with
     the same values for parameters `a`, `c` and `m`.
     In other words if the LCG `other` produces the
     same sequence as this one, even if their current states are different."
    shared actual Boolean equals(Object other) {
        if (is LCG other) {
            return a == other.a
                    && c == other.c
                    && m == other.m;
        }
        return false;
    }

    "Returns `a.xor(c).xor(m)` to be compatible with [[equals]]."
    shared actual Integer hash => a.xor(c).xor(m);

}
