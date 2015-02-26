/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import de.anhnhan.entity {
    EntityManager,
    Query
}
import de.anhnhan.web {
    Application,
    Controller,
    ApplicationContext,
    BaseApplication,
    RequestStack,
    ApplicationHandler
}

import ceylon.collection {
    HashMap,
    MutableMap
}
import ceylon.language.meta.declaration {
    ClassDeclaration
}
import ceylon.language.meta.model {
    Class
}

shared interface DefaultEntityManagerDomain
    of defaultEntityManagerDomain
{}

shared object defaultEntityManagerDomain satisfies DefaultEntityManagerDomain {}

shared interface ApplicationWithEntities
        satisfies Application
{
    shared formal EntityManager entityManager(DefaultEntityManagerDomain|String domain = defaultEntityManagerDomain);
}

shared interface ControllerWithEntities
    satisfies Controller
{
    shared formal actual ApplicationWithEntities app;

    shared default EntityManager entityManager(DefaultEntityManagerDomain|String domain = defaultEntityManagerDomain) => app.entityManager(domain);

    shared default Query_ query<Query_>(Class<Query_, [EntityManager]> queryClass, DefaultEntityManagerDomain|String domain = defaultEntityManagerDomain)
        given Query_ satisfies Query
    {
        return queryClass(entityManager(domain));
    }
}

shared abstract class BaseApplicationWithEntities(ApplicationContext context, ClassDeclaration* controllerDeclarations)
    extends BaseApplication(context, *controllerDeclarations)
    satisfies ApplicationWithEntities
{
    shared formal EntityManager buildEntityManager(DefaultEntityManagerDomain|String domain);

    MutableMap<DefaultEntityManagerDomain|String, EntityManager> entityManagers = HashMap<DefaultEntityManagerDomain|String, EntityManager>();

    shared actual EntityManager entityManager(DefaultEntityManagerDomain|String domain)
    {
        if (exists em = entityManagers[domain])
        {
            return em;
        }

        value em = buildEntityManager(domain);
        entityManagers.put(domain, em);
        return em;
    }
}

shared abstract class ApplicationHandlerWithEntities(app, RequestStack requestStack)
                               // yeah, ima passing nothing!
    extends ApplicationHandler(nothing, requestStack)
    satisfies ControllerWithEntities
{
    shared actual default ApplicationWithEntities app;
}
