/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    HashMap,
    MutableMap
}

shared interface RequestResponse
        of Response | Redirect | NotModified
{
    shared formal StatusCode httpCode;
    shared formal MutableMap<String, String> headers;
}

shared interface Redirect
    satisfies RequestResponse
{
    shared formal String redirectTo;
}

shared final class RedirectResponse(
    redirectTo,
    {<String->String>*} _headers,
    "Whether this redirect is permanent (should be remembered by the client)."
    // This defaults to false for less trips by devs (I'm talking about the guy reading this)
    Boolean permanent = false
)
    satisfies Redirect
{
    shared actual String redirectTo;
    // TODO: Did I use the right code? It's been a *long* time since I did this.
    shared actual StatusCode httpCode = permanent then httpPermanentlyRedirect else httpTemporaryRedirect;
    shared actual MutableMap<String, String> headers = HashMap { entries = _headers; };
}

shared interface NotModified
    satisfies RequestResponse
{
    //
}

shared final class NotModifiedResponse({<String->String>*} _headers)
    satisfies NotModified
{
    // TODO: Did I use the right code? It's been a *long* time since I did this.
    shared actual StatusCode httpCode = httpNotModified;
    shared actual MutableMap<String, String> headers = HashMap { entries = _headers; };
}
