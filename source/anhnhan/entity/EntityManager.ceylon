/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.language.meta.declaration {
    ClassOrInterfaceDeclaration
}

// APIs are taken from the Doctrine project

shared interface ObjectRepository<EntityType>
    given EntityType satisfies Object
{
    shared formal EntityType? find(Id|Uid id);

    shared formal Set<EntityType> findBy();

    shared formal EntityType? findOneBy();
}

shared interface ORMConfiguration
{
}

shared interface ObjectManager
{
    shared EntityType? find<EntityType>(ClassOrInterfaceDeclaration type, Id|Uid id)
        given EntityType satisfies Object
        => repository<EntityType>(type)?.find(id);

    shared formal void insert<EntityType>(EntityType entity)
        given EntityType satisfies Object;

    shared formal void update<EntityType>(EntityType entity)
        given EntityType satisfies Object;

    shared formal void remove<EntityType>(EntityType entity)
        given EntityType satisfies Object;

    shared formal void flush();

    shared formal ObjectRepository<EntityType>? repository<EntityType>(ClassOrInterfaceDeclaration type)
        given EntityType satisfies Object;
}

shared interface EntityManager
    satisfies ObjectManager
{
    shared formal void beginTransaction();

    shared formal void commit();

    shared formal void rollback();

    shared default Return|Boolean transactional<Return>(Return(EntityManager) func)
    {
        beginTransaction();
        Return ret;
        try
        {
            ret = func(this);
            commit();
        }
        catch (Exception exc)
        {
            rollback();
            close();
            throw exc;
        }

        if (`Return`.exactly(`Nothing`))
        {
            return ret;
        }
        else
        {
            return true;
        }
    }

    shared formal Object createQuery(String query);

    shared formal void close();
    shared formal Boolean open;
}
