/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
interface CachedRuleReference
        satisfies RuleReference
{
    shared formal
    String cacheBucketName;

    string => "[``name`` (cached)]";
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
