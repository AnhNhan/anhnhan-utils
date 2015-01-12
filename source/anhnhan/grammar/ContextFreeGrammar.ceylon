/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.random {
    LCG
}
import anhnhan.utils {
    pick_random,
    joinStrings
}

import ceylon.collection {
    LinkedList,
    HashMap
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

shared
ContextFreeGrammar<Token> grammar<Token>({Rule<Token>+} _rules, String _startRuleName, Integer _limit = 65536, Boolean checkCorrectness = true)
{
    value map = HashMap { entries = _rules.map((rule) => rule.name->rule); };
    // Category check has provided me confusing results. Do it like a real man
    // instead.
    assert(exists startRule = map[_startRuleName]);

    if (checkCorrectness)
    {
        value _missingRules = _rules.flatMap((rule)
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
            value mapped = joinStrings(missingRules.map((str) => "<``str``>"), ", ");
            throw Exception("Rules ``mapped`` do not exist in grammar. Please check your grammar for any typos.");
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

shared
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
        "Counter to keep track if we exceeded"
        value count = Counter(0, limit, "Token limit exceeded.");
        value rules = this.rules;
        value _startRule = rules[startRuleName];
        if (is Null _startRule)
        {
            throw Exception("Start rule <``startRuleName``> does not exist.");
        }
        assert(exists _startRule);
        return applyRules<Token>([_startRule], count, rules);
    }

    shared default
    {{Token+}+} generateSeveral(Integer count, String startRuleName = this.startRuleName, Integer limit = this.limit)
    {
        assert(count >= 0);
        return (0..count).map((_) => generate(startRuleName, limit));
    }
}

{Token+} applyRules<Token>(Production<Token> inputRule, Counter counter, Map<String, Rule<Token>> rules)
{
    counter.increment();

    value output = LinkedList<{Token+}>();

    for (production in inputRule)
    {
        if (is Rule<Token>|RuleReference production)
        {
            Rule<Token> rule;
            if (is Rule<Token> production)
            {
                rule = production;
            }
            else if (is RuleReference production)
            {
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
            else
            {
                return nothing;
            }
            value randomProduction = pick_random(rule.productions, LCG().random);
            output.add(applyRules(randomProduction, counter, rules));
        }
        if (is Token production)
        {
            output.add({production});
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
