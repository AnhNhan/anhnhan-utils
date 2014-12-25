/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

"An entity that is aware of the transaction system."
shared interface TransactionAwareEntity<out XactTypeType, out XactValueType = String>
    satisfies Entity
    given XactTypeType satisfies TransactionType
    given XactValueType satisfies Object
{
    // Just adding for compiler completion
    field { type = sql_integer; }
    shared formal Id id;

    field { type = sql_string; unique = true; }
    shared formal Uid uid;

    oneToMany(`interface TransactionSet`)
    shared formal {TransactionSet<XactTypeType, TransactionAwareEntity<XactTypeType, XactValueType>, XactValueType>*} transactions;

    oneToOne(`interface TransactionSet`)
    shared formal TransactionSet<XactTypeType, TransactionAwareEntity<XactTypeType, XactValueType>, XactValueType>? currentTransactionSet;

    shared formal UidType uidType;
    shared formal Uid cleanId;
}

"A container of `TransactionValue`s committed together.
 Linked list of transaction sets to build a history of change sets."
shared interface TransactionSet<out XactTypeType, out ObjectType, out XactValueType = String>
    satisfies Entity
    given XactTypeType satisfies TransactionType
    given XactValueType satisfies Object
    given ObjectType satisfies TransactionAwareEntity<XactTypeType, XactValueType>
{
    field { type = sql_string; unique = true; }
    shared formal Uid uid;

    "The collected transactions in this changeset."
    oneToMany(`interface TransactionValue`)
    shared formal {TransactionValue<XactTypeType, ObjectType, XactValueType>*} transactions;

    "The preceding transaction set."
    oneToOne(`interface TransactionSet`)
    shared formal TransactionSet<XactTypeType, ObjectType, XactValueType>? previousSet;

    field { type = sql_string; }
    shared formal Uid objId;

    "The object this transaction set belongs to."
    shared formal ObjectType obj;
}

"Represents a single change against a single field."
shared interface TransactionValue<out XactTypeType, out ObjectType, out Value = String>
    satisfies Entity
    given Value satisfies Object
    given XactTypeType satisfies TransactionType
    given ObjectType satisfies TransactionAwareEntity<XactTypeType, Value>
{
    field { type = sql_string; unique = true; }
    shared formal Uid uid;

    field { type = sql_string; }
    shared formal Uid actorId;

    shared formal Object actor;

    field { type = sql_string; }
    shared formal Uid objId;

    shared formal ObjectType obj;

    field { type = sql_string; }
    shared formal XactTypeType type;

    // TODO: Make sql type switchable with `given Value` changes
    field { type = sql_text; }
    shared formal Value oldValue;

    field { type = sql_text; }
    shared formal Value newValue;

    field { type = sql_json; }
    shared formal Map<String, String> metadata;
}

shared interface TransactionType
{
    shared formal String type;
}
