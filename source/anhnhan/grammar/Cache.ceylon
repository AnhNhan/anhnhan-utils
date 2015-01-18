/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

"A reference to a rule, whose resulting token stream after the application of
 one its productions is being cached. Later cached references (given the same
 [[CachedRuleReference.cacheBucketName]]) will yield the same token stream as
 the first application."
shared
interface CachedRuleReference
        satisfies RuleReference
{
    shared formal
    String cacheBucketName;

    string => "[``name`` (cached in ``cacheBucketName``)]";
}

shared
CachedRuleReference cachedRef(String ruleName, String ruleCacheBucketName = "default")
{
    object ref
            satisfies CachedRuleReference
    {
        name = ruleName;
        cacheBucketName = ruleCacheBucketName;
    }

    return ref;
}
