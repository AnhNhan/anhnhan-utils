/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

"Denotes that a request could not be processed in a satisfiable manner (usually
 HTTP code 4xx-5xx).

 Provides general error case, as well as common specific errors."
shared interface RequestError
    of Error | NotFound | LackingPermission
{
    shared formal StatusCode httpCode;
}

// TODO: Expand this
shared final class Error(httpCode, message = null)
    satisfies RequestError
{
    shared String? message;
    shared actual StatusCode httpCode;
}

shared final class NotFound(message = "The page you wanted to visit does not exist.")
    satisfies RequestError
{
    shared String? message;
    shared actual StatusCode httpCode = httpNotFound;
}

shared final class LackingPermission(message = "You lack the sufficient permissions to visit this page.")
    satisfies RequestError
{
    shared String? message;
    shared actual StatusCode httpCode = httpForbidden;
}
