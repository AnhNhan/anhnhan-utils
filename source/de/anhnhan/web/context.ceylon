/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.language.meta {
    type
}

shared alias ConfigValue => String | Integer | Float | Map<String, String> | {String*};

shared interface ApplicationContext
{
    shared formal
    Map<String, ConfigValue> parameters;
    shared formal
    Map<String, Object> services;


    shared
    throws(`class TooManyServicesException`, "Too many services of a type.")
    throws(`class NonMatchingServiceException`, "Service type does not match expected type.")
    Service? service<Service>(String? name = null)
        given Service satisfies Object
    {
        {<String->Object>*} filtered = {for (service in services) if (is Service service) service};

        if (filtered.empty)
        {
            return null;
        }

        {<String->Object>*} filtered2;

        if (exists name)
        {
            filtered2 = filtered.filter((entry) => entry.key == name);
        }
        else
        {
            filtered2 = filtered;
        }

        if (exists _ = filtered2.rest.first)
        {
            throw TooManyServicesException("Too many services of type '" + `Service`.string + "'!");
        }

        if (exists val = filtered2.first)
        {
            if (is Service service = val.item)
            {
                return service;
            }
            else
            {
                throw NonMatchingServiceException("Service ``name else "<unnamed>"`` of type ``type(val.item)`` does not match expected type ``type(`Service`)``.");
            }
        }
        else
        {
            return null;
        }
    }
}

shared
class TooManyServicesException(String msg)
    extends Exception(msg)
{}

shared
class NonMatchingServiceException(String msg)
    extends Exception(msg)
{}
