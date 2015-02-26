/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import de.anhnhan.random {
    LCG
}
import de.anhnhan.utils {
    pick_random
}

import ceylon.collection {
    LinkedList,
    HashMap,
    MutableMap
}
import ceylon.language.meta {
    type
}

/*
 TODO:
   * Parametric grammars
   * In-Production<T> alternation (provide parametrized Rule(Reference)?)
   * Provide tools to express repetition without recursion
   * Allow to express wish for result transformations during generation
   * Allow to express the chance of a Production to be selected, e.g. some
     should be less likey, while others should be selected in the majority of cases
   * Provide emptiness
   * Grammar checking?
     * Correctness
     * Ambiguity
 */

"Creates a context free grammar from the given rules and grammars. If a grammar
 is passed in, its rules are embedded into the rule set of the created grammar
 (as opposed to [[EmbeddedGrammar]])."
shared
ContextFreeGrammar<Token> grammar<Token>(
    {Rule<Token>|ContextFreeGrammar<Token>+} _rules,
    ""
    String _startRuleName,
    Integer _limit = 65536,
    "If set to [[true]], we will check each of the grammar's rule production
     for invalid references, and throw an exception if any had been found."
    Boolean checkCorrectness = true
)
{
    {<String->Rule<Token>>+} collecting(Rule<Token>|ContextFreeGrammar<Token> obj)
    {
        if (is Rule<Token> obj)
        {
            return {obj.name->obj};
        }
        else
        {
            assert(is ContextFreeGrammar<Token> obj);
            value rules = obj.rules.items.collect((Rule<Token> rule) => rule.name->rule);
            if (nonempty rules)
            {
                return rules;
            }
            else
            {
                throw Exception("Received an empty grammar, can't embed it.");
            }
        }
    }
    value map = HashMap { entries = _rules.flatMap(collecting); };
    // Category check has provided me confusing results. Do it like a real man
    // instead.
    assert(exists startRule = map[_startRuleName]);

    if (checkCorrectness)
    {
        value _missingRules = map.items.flatMap((rule)
            => rule.productions.flatMap((production)
            => production.collect((element)
                {
                    if (is RuleReference element)
                    {
                        value rule = map[element.name];
                        if (is Null rule)
                        {
                            return element.name;
                        }
                    }

                    return null;
                })));
        if (nonempty missingRules = _missingRules.coalesced.sequence())
        {
            value mapped = missingRules.map((str) => "<``str``>").reduce((String x, y) => x + ", " + y);
            throw Exception("Rule(s) ``mapped`` do not exist in the grammar. Please check your grammar for any typos.");
        }
    }

    object grammar
            satisfies ContextFreeGrammar<Token>
    {
        limit = _limit;
        startRuleName = _startRuleName;
        rules = map;
    }

    return grammar;
}

shared see(`function grammar`)
interface ContextFreeGrammar<Token>
{
    "Arbitrary limit for number of tokens."
    shared formal
    Integer limit;

    shared formal
    String startRuleName;

    shared formal
    Map<String, Rule<Token>> rules;

    shared default throws(`class Exception`, "the token limit is exceeded.") throws(`class Exception`, "a rule has not been found.")
    {Token+} generate(String startRuleName = this.startRuleName, Integer limit = this.limit)
    {
        "Counter to keep track whether we exceeded the token limit"
        value count = Counter(0, limit, "Token limit of ``limit`` exceeded.");
        value rules = this.rules;
        value _startRule = rules[startRuleName];
        value productionCache = HashMap<[String, String], {Token+}>();
        if (is Null _startRule)
        {
            throw Exception("Start rule <``startRuleName``> does not exist.");
        }
        assert(exists _startRule);
        return applyRules<Token>([_startRule], count, rules, productionCache);
    }

    shared default
    {{Token+}+} generateSeveral(Integer count, String startRuleName = this.startRuleName, Integer limit = this.limit)
    {
        assert(count >= 0);
        return (0..count).map((_) => generate(startRuleName, limit));
    }

    string => "``type(this)``\n``rules``";
}

{Token+} applyRules<Token>(Production<Token> inputRule, Counter counter, Map<String, Rule<Token>> rules, MutableMap<[String, String], {Token+}> productionCache)
{
    counter.increment();

    value output = LinkedList<{Token+}>();

    for (production in inputRule)
    {
        if (is NonTerminal<Token> production)
        {
            Rule<Token> rule;
            switch (production)
            case (is Rule<Token>)
            {
                rule = production;
            }
            case (is RuleReference)
            {
                if (is CachedRuleReference production, exists cachedProduction = productionCache[[production.name, production.cacheBucketName]])
                {
                    output.add(cachedProduction);
                    continue;
                }
                value _rule = rules[production.name];
                if (exists _rule)
                {
                    rule = _rule;
                }
                else
                {
                    throw Exception("Rule ``production.name`` has not been found.");
                }
            }

            value randomProduction = pick_random(rule.productions, LCG().random);
            value applied = applyRules(randomProduction, counter, rules, productionCache);

            if (is CachedRuleReference production)
            {
                productionCache.put([production.name, production.cacheBucketName], applied);
            }

            output.add(applied);
        }
        else if (is Token production)
        {
            output.add({production});
        }
        else
        {
            value t = className(production else 0);
            throw Exception("Unaccounted case for ``production else "<null>"`` (``t.string``)");
        }
    }

    assert(nonempty _output = output.sequence());
    value _return = _output.reduce(({Token+} partial, element) => partial.chain(element));
    return _return;
}

class Counter(
    shared variable
    Integer count,
    shared
    Integer? limit = null,
    shared
    String? limitMsg = null
)
{
    if (exists limit)
    {
        "Counter limit has to be strictly positive."
        assert(limit.positive);
    }

    shared
    void increment()
    {
        count++;

        if (exists limit, exceeds(limit))
        {
            if (exists limitMsg)
            {
                throw Exception(limitMsg);
            }
            else
            {
                throw Exception("Counter limit of ``limit`` exceeded.");
            }
        }
    }

    shared
    Boolean exceeds(Integer limit)
            => count > limit;
}
