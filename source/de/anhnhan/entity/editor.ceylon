/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import de.anhnhan.utils {
    _nonempty
}

"What to do when the transaction has no calculated effect."
shared interface NoEffectBehavior
    of noEffect_Skip | noEffect_Error | noEffect_Ignore
{}

"Skip the transaction when it has no effect. It will not be persisted
 in any case."
object noEffect_Skip satisfies NoEffectBehavior {}
"Emit an error when a transaction has no effect. The operation will
 be aborted."
object noEffect_Error satisfies NoEffectBehavior {}
"Ignore the error when a transaction has no effect. It will be persisted,
 and the operation continues as usual."
object noEffect_Ignore satisfies NoEffectBehavior {}

"How or when to flush the persistence queue (if at all)."
shared interface FlushBehavior
    of flushDontFlush | flushFlush | flushDeferFlush
{}

"Don't flush at all. You will have to invoke flush manually."
object flushDontFlush satisfies FlushBehavior {}
"Do both flushes as soon as they occurr. This will invoke two flushes."
object flushFlush satisfies FlushBehavior {}
"Only flush once, at the end. May cause problems if you create values
 which depend on the flushed main object (like generated id attributes)."
object flushDeferFlush satisfies FlushBehavior {}

"A generic editor for applying transactions against transaction-aware objects."
shared interface Editor<out XactSet>
{
    shared formal NoEffectBehavior noEffectBehavior;
    shared formal FlushBehavior flushBehavior;

    shared formal XactSet apply();
}

"A generic editor for applying transactions against transaction-aware objects.

 NOTE: Currently we only support the default value type for TransactionValue,
 TransactionSet and TransactionAwareEntity (that's `String`). This is due to
 else having lots of complexity in handling lots of generic parameters."
shared abstract class TransactionEditor
    <
        XactType,
        Obj = TransactionAwareEntity<XactType>,
        Xact = TransactionValue<XactType, Obj>,
        XactSet = TransactionSet<XactType, Obj>
    >
    (
        "Currently only the Uid of the actor, may or may not change to Uid|Actor or Just<Actor> in the future."
        shared Uid actor,
        "The entity object to apply transactions against."
        shared Obj entity,
        "The transactions we have to apply."
        variable {Xact*} transactions
    )
    satisfies Editor<XactSet>
    given XactType satisfies TransactionType
    given Xact satisfies TransactionValue<XactType, Obj>
    given XactSet satisfies TransactionSet<XactType, Obj>
    given Obj satisfies TransactionAwareEntity<XactType>
{
    "Specifies the behavior in the case that applying a transaction yields no noticable effect."
    see(`interface NoEffectBehavior`)
    shared actual variable NoEffectBehavior noEffectBehavior = noEffect_Skip;
    "Specifies the behavior for flushing."
    see(`interface FlushBehavior`)
    shared actual variable FlushBehavior flushBehavior = flushDeferFlush;

    "This is the plughole to create your own persistable TransactionSet instance
     that you know how to persist on your own in `persistTransactionSet(TransactionSet)`."
    shared formal XactSet createTransactionSet(Obj entity, {Xact*} transactions);
    "Persist (or queue up to persist) a TransactionSet instance."
    shared formal void persistTransactionSet(XactSet xactSet);

    "Persist (or queue up to persist) an entity instance."
    shared formal void persistObject(Obj entity);
    "Persist (or queue up to persist) a TransactionValue instance."
    shared formal void persistTransaction(Xact xact);

    "Flush the persistence queue. If we don't have a persistence queue, well, waste a function call."
    shared formal void flushEntities();

    "Calculate the oldValue for an `xact`.

     Usually this just involves getting the current value of the `entity`."
    shared formal Anything getTransactionOldValue(Obj entity, Xact xact);
    "Calculate the newValue for an `xact`.

     Usually this just involves returning `xact.newValue`."
    shared formal Anything getTransactionNewValue(Obj entity, Xact xact);

    "Apply the effects of `xact` on `entity`.

     Usually it's as simple as writing on an attribute, but in some cases more has to be done."
    shared formal void applyTransactionEffects(Obj entity, Xact xact);

    "Apply changes to a transaction itself.

     We just need to set some properties. Override if you use your own property implementation."
    shared default void applyEffectOnTransaction<Xact, Value>(Xact xact, String name, Value val)
        given Xact satisfies TransactionValue<XactType, Obj>
    {
        switch (xact)
        case (is SpeciallyMutableEntity)
        {
            xact.setValue(name, val);
        }
        else
        {
            throw Exception("Don't know how to handle xacts of type ``className(xact)``");
        }
    }

    shared formal Boolean transactionHasEffect(Obj entity, Xact xact);

    "You can do post-flush actions here. Default is a stub."
    shared default void postApplyHook(Obj entity, {Xact*} _xacts)
    {
        // ...
    }

    "Apply all your pent up transactions. Yes, let them all out!

     We don't recommend invoking this method more than once."
    shared actual XactSet apply()
    {
        value xacts = transactions;
        if (xacts.empty)
        {
            return createTransactionSet(entity, xacts);
        }

        for (xact in xacts)
        {
            value test = _nonempty(xact.uid, xact.actorId, xact.objId, xact.oldValue);
            assert(test.empty);

            applyEffectOnTransaction(xact, "actorId", actor);
            applyEffectOnTransaction(xact, "obj", entity);
        }

        for (xact in xacts)
        {
            value oldValue = getTransactionOldValue(entity, xact);
            applyEffectOnTransaction(xact, "oldValue", oldValue);

            value newValue = getTransactionNewValue(entity, xact);
            applyEffectOnTransaction(xact, "newValue", newValue);
        }

        variable {Xact*} _xacts = {};
        for (xact in xacts)
        {
            value noEffect = !transactionHasEffect(entity, xact);

            if (noEffect)
            {
                switch (noEffectBehavior)
                case (noEffect_Error)
                {
                    "Transaction has no effect!"
                    assert(false);
                }
                case (noEffect_Skip)
                {
                    // ...
                }
                case (noEffect_Ignore)
                {
                    // Add it nonetheless
                    _xacts = {xact, *_xacts};
                }
            }
            else
            {
                _xacts = {xact, *_xacts};
            }

            applyTransactionEffects(entity, xact);
        }

        for (xact in _xacts)
        {
            persistTransaction(xact);
        }

        persistObject(entity);

        value xactSet = createTransactionSet(entity, _xacts);
        persistTransactionSet(xactSet);

        if (flushBehavior == flushFlush)
        {
            flushEntities();
        }

        // TODO: Persist-later stuff ...

        if (flushBehavior != flushDontFlush)
        {
            flushEntities();
        }

        postApplyHook(entity, _xacts);

        return xactSet;
    }
}
