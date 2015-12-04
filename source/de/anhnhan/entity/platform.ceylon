/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

"This type is used to enumerate the different types.

 Currently it is only an exhaustive enumeration, there may be changes in
 this regard though once we support custom types for custom serialization
 handlers.

 TODO: Consider multi-column types, e.g. for datetime + timezone + dst?

 Note: Due to the use in annotations this is an abstract class instead of
 an interface (bug?). Also, CommonBuiltInSqlTypes and CustomSqlType are disabled.
 "
shared abstract class SqlType(name)
    of sql_string
        | sql_text
        | sql_integer
        | sql_boolean
        | sql_float
        | sql_datetime
        | sql_json
        | sql_uuid
     // | CommonBuiltInSqlTypes
     // | CustomSqlType
{
    shared String name;
}

shared object sql_string extends SqlType("string")
{}
shared object sql_text extends SqlType("text")
{}
shared object sql_integer extends SqlType("integer")
{}
shared object sql_boolean extends SqlType("boolean")
{}
shared object sql_float extends SqlType("float")
{}
shared object sql_datetime extends SqlType("datetime")
{}
"Persist JSON.like data structures in a database.

 For DB engines which support JSON types, we use that. For other DB engines
 we serialize to actual JSON and store that in a CLOB."
shared object sql_json extends SqlType("json")
{}
shared object sql_uuid extends SqlType("uuid")
{}
/*
"Not intended for userland code.

 This is simply to have common aliases."
abstract class CommonBuiltInSqlTypes(String name)
    extends SqlType(name)
{}
"Extend from CustomSqlType for your own type extensions."
shared abstract class CustomSqlType(String name)
    extends SqlType(name)
{}
*/


"An enumeration of supported databases.

 Also codifies some aspects of how to handle platform-specific things
 like types."
shared interface DbPlatform
    of db_mysql | db_pgsql
{
    shared formal String name;

    shared formal String sqlTypeDeclarationFor(SqlType type, FieldAnnotation? field);
}

shared object db_mysql
    satisfies DbPlatform
{
    shared actual String name = "MySql";

    shared actual String sqlTypeDeclarationFor(SqlType type, FieldAnnotation? field)
    {
        switch (type)
        case (sql_datetime)
        {
            return "DATETIME";
        }
        case (sql_boolean)
        {
            return "TINYINT(1)";
        }
        else
        {
            return genericSqlTypeDeclaration(type, field, this);
        }
    }
}

shared object db_pgsql
    satisfies DbPlatform
{
    shared actual String name = "PostgreSql";

    shared actual String sqlTypeDeclarationFor(SqlType type, FieldAnnotation? field)
    {
        switch (type)
        case (sql_datetime)
        {
            return "TIMESTAMP(0) WITHOUT TIME ZONE";
        }
        case (sql_uuid)
        {
            return "UUID";
        }
        case (sql_json)
        {
            return "JSON";
        }
        case (sql_boolean)
        {
            return "BOOLEAN";
        }
        else
        {
            return genericSqlTypeDeclaration(type, field, this);
        }
    }
}

"Sane defaults for sql type declaractions, shared across platforms."
String genericSqlTypeDeclaration(SqlType type, FieldAnnotation? field, DbPlatform platform)
{
    switch (type)
    case (sql_integer)
    {
        // TODO: Add SERIAL/AUTO INCREMENT modifiers
        return "INT";
    }
    case (sql_float)
    {
        return "DOUBLE PRECISION";
    }
    case (sql_text)
    {
        return "TEXT";
    }
    case (sql_string)
    {
        variable Integer length = 255;
        if (exists field)
        {
            length = field.length > 0 then field.length else length;
        }
        return "VARCHAR(``length``)";
    }
    case (sql_uuid)
    {
        // Delegate to string/varchar
        return genericSqlTypeDeclaration(sql_string, field, platform);
    }
    case (sql_json)
    {
        // Delegate to text/clob
        return genericSqlTypeDeclaration(sql_text, field, platform);
    }
    case (sql_datetime | sql_boolean)
    {
        throw Exception("No sane defaults for type ``type.name`` (on platform ``platform.name``)");
    }
}
