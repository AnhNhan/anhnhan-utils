/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.utils {
    compareByKey,
    sumInterjected
}

import ceylon.collection {
    MutableMap,
    Stack,
    LinkedList
}

// These two only aren't aliases because `Stack` doesn't have a size property
shared interface RequestStack
    satisfies {Request*} & Stack<Request>
{}
shared final class RequestStackImpl({Request*} requests)
    extends LinkedList<Request>(requests)
    satisfies RequestStack
{}

shared alias RequestParameter => String | {String*} | Map<String, String>;

shared interface RequestParameters
{
    shared formal MutableMap<String, String> attributes;
    shared formal Map<String, RequestParameter> post;
    shared formal Map<String, RequestParameter> query;
    shared formal Map<String, String> server;
    shared formal Map<String, String> cookies;
}

shared interface HttpAuthInfo
{
    shared formal String user;
    shared formal String? password;
}

shared interface Request
{
    shared formal Map<String, String> headers;
    shared formal Map<String, Map<String, String>> files;

    shared formal RequestParameters parameters;
    shared formal HttpAuthInfo? httpAuth;

    shared formal String? content;
    shared formal String[] languages;
    shared formal String[] charsets;
    shared formal String[] encodings;
    shared formal String[] acceptableContentTypes;
    shared formal String pathInfo;
    shared formal String scriptName;
    shared formal String requestUri;
    shared formal String? baseUrl;
    shared formal String? basePath;
    shared formal HttpMethod method;
    shared formal String format;
    shared formal String scheme;
    shared formal Boolean secure;
    shared formal Integer? port;
    shared formal Session? session;
    shared formal String locale;
    shared formal String[] formats;

    shared formal String httpHost;

    shared default RequestParameter? get(Object key, RequestParameter? default = null)
    {
        return parameters.query[key] else parameters.attributes[key] else parameters.post[key] else default;
    }
}

shared interface HttpMethod
    of http_get | http_post | http_put | http_head | http_delete | http_trace | http_options | http_connect | http_patch
{}

shared object http_get satisfies HttpMethod {}
shared object http_post satisfies HttpMethod {}
shared object http_put satisfies HttpMethod {}
shared object http_head satisfies HttpMethod {}
shared object http_delete satisfies HttpMethod {}
shared object http_trace satisfies HttpMethod {}
shared object http_options satisfies HttpMethod {}
shared object http_connect satisfies HttpMethod {}
shared object http_patch satisfies HttpMethod {}

String normalizeQueryString(String queryString)
{
    if (queryString.empty)
    {
        return queryString;
    }

    function splitPair(Boolean splitting(Character char))(String input)
    {
        value split = input.split(splitting);
        return (split.first else nothing) -> split.rest.first;
    }

    value parts = {
        for (param in queryString.split('&'.equals))
            if (!(param.empty || (param.first?.equals('=') else false)))
                splitPair('='.equals)(param)
    };

    if (parts.empty)
    {
        return queryString;
    }

    // .sort does not respect Absent parameter of Iterable, so we sort before
    // the type narrowing to avoid reverting back to possibly-empty type
    value sorted = parts.sort(compareByKey<String>);
    assert(is {<String->String?>+} _parts = sorted);

    return _parts
        .map((String->String? pair) { if (exists item = pair.item) { return pair.key + "=" + item; } else { return pair.key; }})
        .reduce(sumInterjected("&"))
    ;
}
