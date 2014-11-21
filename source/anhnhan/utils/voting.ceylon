/**
    SupplyRunner Source Code

    Not disclosed to public
    share with anhnhan@outlook.com in case of violation
*/

import ceylon.collection {
    ArrayList
}
import ceylon.test {
    test,
    assertEquals
}

// Adapted port of Symfony's AccessDecisionManager

"An attribute of the voting process. Kind of tags. Interprete how you want."
shared interface VotingAttribute
{
    shared formal String name;
}

"The enumeration of the values a voter can contribute with in the vote."
shared abstract class VotingDecision(val)
    of granted | abstain | denied
{
    Integer val;
}

shared object granted extends VotingDecision(1) {}
shared object abstain extends VotingDecision(0) {}
shared object denied extends VotingDecision(-1) {}

"A voting strategy declares how a decision is reached from the votes."
shared abstract class VotingStrategy()
    of affirmative | majority | unanimous
{}

"The decision is true once at least one granting vote has been received."
shared object affirmative extends VotingStrategy() {}
"The decision is true only if the number granting votes exceed the number of denying votes."
shared object majority extends VotingStrategy() {}
"Allow only, and only if no deny votes have been received."
shared object unanimous extends VotingStrategy() {}

"A voter takes part in the voting process and votes based up"
shared interface Voter<in AccessToken, in Obj = Object>
    given Obj satisfies Object
{
    "Whether this voter can give reasonable judgements about the requested attribute."
    shared formal Boolean supportsAttribute(VotingAttribute attribute);
    "Whether this voter can reason about the given object. You may do both type and value checks."
    shared formal Boolean supportsClass(Anything cls);

    shared formal VotingDecision vote(AccessToken token, Obj? obj, VotingAttribute* attributes);
}

shared class VotingManager<in AccessToken, in Obj = Object>(
        "The voters taking part in decision making."
        shared {Voter<AccessToken, Obj>*} voters,
        "How to value the single votes to reach a decision."
        shared VotingStrategy strategy,
        "Whether to pass objects even if no voter gave a clear vote."
        Boolean allowIfAllAbstainDecisions = false,
        "Whether to pass objects even in the event of a tie during a majority vote."
        Boolean allowIfEqualGrantedDeniedDecisions = true)
    given Obj satisfies Object
{
    "Can't have no voters, can we?"
    assert (!voters.empty);

    "Whether a voter supporting this attribute takes part in decision making."
    shared Boolean supportsAttribute(VotingAttribute attribute)
    {
        return voters.any((Voter<AccessToken,Obj> voter) => voter.supportsAttribute(attribute));
    }

    "Whether a voter supporting this class takes part in decision making."
    shared Boolean supportsClass(Anything cls)
    {
        return voters.any((Voter<AccessToken,Obj> voter) => voter.supportsClass(cls));
    }

    shared Boolean decide(AccessToken token, {VotingAttribute*} attributes, Obj? obj = null)
    {
        switch (strategy)
        case (affirmative)
        {
            return decideAffirmative(token, attributes, obj);
        }
        case (majority)
        {
            return decideMajority(token, attributes, obj);
        }
        case (unanimous)
        {
            return decideUnanimous(token, attributes, obj);
        }
    }

    Boolean decideAffirmative(AccessToken token, {VotingAttribute*} attributes, Obj? obj = null)
    {
        variable value deniedCount = 0;

        for (voter in voters)
        {
            switch (voter.vote(token, obj, *attributes))
            case (granted)
            {
                return true;
            }
            case (denied)
            {
                deniedCount++;
            }
            case (abstain)
            {
                // ...
            }
        }

        if (deniedCount > 0)
        {
            return false;
        }

        return allowIfAllAbstainDecisions;
    }

    Boolean decideMajority(AccessToken token, {VotingAttribute*} attributes, Obj? obj = null)
    {
        variable value grantedCount = 0;
        variable value abstainCount = 0;
        variable value deniedCount  = 0;

        for (voter in voters)
        {
            switch (voter.vote(token, obj, *attributes))
            case (granted)
            {
                grantedCount++;
            }
            case (denied)
            {
                deniedCount++;
            }
            case (abstain)
            {
                abstainCount++;
            }
        }

        if (grantedCount > deniedCount) {
            return true;
        }

        if (deniedCount > grantedCount) {
            return false;
        }

        if (grantedCount == deniedCount && grantedCount != 0) {
            return allowIfEqualGrantedDeniedDecisions;
        }

        return allowIfAllAbstainDecisions;
    }

    Boolean decideUnanimous(AccessToken token, {VotingAttribute*} attributes, Obj? obj = null)
    {
        variable value grantedCount = 0;

        for (voter in voters)
        {
            switch (voter.vote(token, obj, *attributes))
            case (granted)
            {
                grantedCount++;
            }
            case (denied)
            {
                return false;
            }
            case (abstain)
            {
                // ...
            }
        }

        if (grantedCount > 0)
        {
            return true;
        }

        return allowIfAllAbstainDecisions;
    }
}

// ------------------------------
//             Tests
// ------------------------------

test
void testSupportClass()
{
    object supports_class satisfies Voter<Anything, Object>
    {
        shared actual Boolean supportsAttribute(VotingAttribute attribute) => nothing;
        shared actual VotingDecision vote(Anything token, Object? obj, VotingAttribute* attributes) => nothing;

        shared actual Boolean supportsClass(Anything cls) => true;
    }

    object unsupported_class satisfies Voter<Anything, Object>
    {
        shared actual Boolean supportsAttribute(VotingAttribute attribute) => nothing;
        shared actual VotingDecision vote(Anything token, Object? obj, VotingAttribute* attributes) => nothing;

        shared actual Boolean supportsClass(Anything cls) => false;
    }

    value votingManager1 = VotingManager([supports_class, unsupported_class], affirmative);
    assert( votingManager1.supportsClass(abstain));

    value votingManager2 = VotingManager([unsupported_class, unsupported_class], affirmative);
    assert(!votingManager2.supportsClass(abstain));
}

test
void testSupportAttributes()
{
    object attribute_supported satisfies Voter<Anything, Object>
    {
        shared actual Boolean supportsClass(Anything cls) => nothing;
        shared actual VotingDecision vote(Anything token, Object? obj, VotingAttribute* attributes) => nothing;

        shared actual Boolean supportsAttribute(VotingAttribute attribute) => true;
    }

    object attribute_unsupported satisfies Voter<Anything, Object>
    {
        shared actual Boolean supportsClass(Anything cls) => nothing;
        shared actual VotingDecision vote(Anything token, Object? obj, VotingAttribute* attributes) => nothing;

        shared actual Boolean supportsAttribute(VotingAttribute attribute) => false;
    }

    object attr_dummy satisfies VotingAttribute
    {
        shared actual String name => nothing;
    }

    value votingManager1 = VotingManager([attribute_supported, attribute_unsupported], affirmative);
    assert( votingManager1.supportsAttribute(attr_dummy));

    value votingManager2 = VotingManager([attribute_unsupported, attribute_unsupported], affirmative);
    assert(!votingManager2.supportsAttribute(attr_dummy));
}

test
void testVotingResults()
{
    alias Vtr => Voter<Anything, Object>;

    Vtr voter(VotingDecision decision)
    {
        object vtr satisfies Voter<Anything, Object>
        {
            shared actual Boolean supportsAttribute(VotingAttribute attribute) => nothing;
            shared actual Boolean supportsClass(Anything cls) => nothing;

            shared actual VotingDecision vote(Anything token, Object? obj, VotingAttribute* attributes) => decision;
        }

        return vtr;
    }

    {Vtr*} voters(Integer grantedCount, Integer deniedCount, Integer abstainedCount)
    {
        value list = ArrayList<Vtr>();

        if (grantedCount > 0)
        {
            for (ii in 0..grantedCount - 1)
            {
                list.add(voter(granted));
            }
        }
        if (deniedCount > 0)
        {
            for (ii in 0..deniedCount - 1)
            {
                list.add(voter(denied));
            }
        }
        if (abstainedCount > 0)
        {
            for (ii in 0..abstainedCount - 1)
            {
                list.add(voter(abstain));
            }
        }

        return list;
    }

    value testdata = {
        // affirmative
        [affirmative, voters(1, 0, 0), false, true, true],
        [affirmative, voters(1, 2, 0), false, true, true],
        [affirmative, voters(0, 1, 0), false, true, false],
        [affirmative, voters(0, 0, 1), false, true, false],
        [affirmative, voters(0, 0, 1), true, true, true],

        // consensus
        [majority, voters(1, 0, 0), false, true, true],
        [majority, voters(1, 2, 0), false, true, false],
        [majority, voters(2, 1, 0), false, true, true],

        [majority, voters(0, 0, 1), false, true, false],

        [majority, voters(0, 0, 1), true, true, true],

        [majority, voters(2, 2, 0), false, true, true],
        [majority, voters(2, 2, 1), false, true, true],

        [majority, voters(2, 2, 0), false, false, false],
        [majority, voters(2, 2, 1), false, false, false],

        // unanimous
        [unanimous, voters(1, 0, 0), false, true, true],
        [unanimous, voters(1, 0, 1), false, true, true],
        [unanimous, voters(1, 1, 0), false, true, false],

        [unanimous, voters(0, 0, 2), false, true, false],
        [unanimous, voters(0, 0, 2), true, true, true]
    };

    object vote_attribute satisfies VotingAttribute
    {
        shared actual String name = "foo";
    }

    void testStrategies(VotingStrategy strategy, {Vtr*} voters, Boolean allowIfAllAbstainDecisions, Boolean allowIfEqualGrantedDeniedDecisions, Boolean expected)
    {
        value manager = VotingManager<Anything, Object>(voters, strategy, allowIfAllAbstainDecisions, allowIfEqualGrantedDeniedDecisions);
        assertEquals(manager.decide("foo", {vote_attribute}), expected);
    }

    for (test in testdata)
    {
        testStrategies(test[0], test[1], test[2], test[3], test[4]);
    }
}
