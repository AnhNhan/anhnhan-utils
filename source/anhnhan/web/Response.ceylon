/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    MutableMap,
    TreeMap
}

shared interface Response
    satisfies RequestResponse
{
    // Just adding these here to be explicit
    shared actual formal variable StatusCode httpCode;
    shared actual formal MutableMap<String, String> headers;
}

shared abstract class StatusCode(code)
    of CustomStatusCode
        | httpContinue
        | httpSwitchingProtocols
        | httpProcessing // RFC2518

        | httpOk
        | httpCreated
        | httpAccepted
        | httpNonAuthoritativeInformation
        | httpNoContent
        | httpResetContent
        | httpPartialContent
        | httpMultiStatus // RFC4918
        | httpAlreadyReported // RFC5842
        | httpImUsed // RFC3229

        | httpMultipleChoices
        | httpMovedPermanently
        | httpFound
        | httpSeeOther
        | httpNotModified
        | httpUseProxy
        | httpReserved
        | httpTemporaryRedirect
        | httpPermanentlyRedirect // RFC-reschke-http-status-308-07

        | httpBadRequest
        | httpUnauthorized
        | httpPaymentRequired
        | httpForbidden
        | httpNotFound
        | httpMethodNotAllowed
        | httpNotAcceptable
        | httpProxyAuthenticationRequired
        | httpRequestTimeout
        | httpConflict
        | httpGone
        | httpLengthRequired
        | httpPreconditionFailed
        | httpRequestEntityTooLarge
        | httpRequestUriTooLong
        | httpUnsupportedMediaType
        | httpRequestedRangeNotSatisfiable
        | httpExpectationFailed
        | httpIAmATeapot // RFC2324
        | httpUnprocessableEntity // RFC4918
        | httpLocked // RFC4918
        | httpFailedDependency // RFC4918
        | httpReservedForWebdavAdvancedCollectionsExpiredProposal // RFC2817
        | httpUpgradeRequired // RFC2817
        | httpPreconditionRequired // RFC6585
        | httpTooManyRequests // RFC6585
        | httpRequestHeaderFieldsTooLarge // RFC6585

        | httpInternalServerError
        | httpNotImplemented
        | httpBadGateway
        | httpServiceUnavailable
        | httpGatewayTimeout
        | httpVersionNotSupported
        | httpVariantAlsoNegotiatesExerimental // RFC2295
        | httpInsufficientStorage // RFC4918
        | httpLoopDetected // RFC5842
        | httpNotExtended // RFC2774
        | httpNetworkAuthenticationRequired // RFC6585
{
    shared Integer code;

    shared String? statusText = statusTextMap.get(code);

    shared actual Boolean equals(Object that)
    {
        if (is StatusCode that) {
            return code == that.code;
        }

        return false;
    }
}

shared final class CustomStatusCode(Integer code)
    extends StatusCode(code)
{}

shared object httpContinue
    extends StatusCode(100) {}
shared object httpSwitchingProtocols
    extends StatusCode(101) {}
shared object httpProcessing
    extends StatusCode(102) {}

shared object httpOk
    extends StatusCode(200) {}
shared object httpCreated
    extends StatusCode(201) {}
shared object httpAccepted
    extends StatusCode(202) {}
shared object httpNonAuthoritativeInformation
    extends StatusCode(203) {}
shared object httpNoContent
    extends StatusCode(204) {}
shared object httpResetContent
    extends StatusCode(205) {}
shared object httpPartialContent
    extends StatusCode(206) {}
shared object httpMultiStatus
    extends StatusCode(207) {}
shared object httpAlreadyReported
        extends StatusCode(208) {}
shared object httpImUsed
        extends StatusCode(226) {}

shared object httpMultipleChoices
        extends StatusCode(300) {}
shared object httpMovedPermanently
        extends StatusCode(301) {}
shared object httpFound
        extends StatusCode(302) {}
shared object httpSeeOther
        extends StatusCode(303) {}
shared object httpNotModified
        extends StatusCode(304) {}
shared object httpUseProxy
        extends StatusCode(305) {}
shared object httpReserved
        extends StatusCode(306) {}
shared object httpTemporaryRedirect
        extends StatusCode(307) {}
shared object httpPermanentlyRedirect
        extends StatusCode(308) {}

shared object httpBadRequest
        extends StatusCode(400) {}
shared object httpUnauthorized
        extends StatusCode(401) {}
shared object httpPaymentRequired
        extends StatusCode(402) {}
shared object httpForbidden
        extends StatusCode(403) {}
shared object httpNotFound
        extends StatusCode(404) {}
shared object httpMethodNotAllowed
        extends StatusCode(405) {}
shared object httpNotAcceptable
        extends StatusCode(406) {}
shared object httpProxyAuthenticationRequired
        extends StatusCode(407) {}
shared object httpRequestTimeout
        extends StatusCode(408) {}
shared object httpConflict
        extends StatusCode(409) {}
shared object httpGone
        extends StatusCode(410) {}
shared object httpLengthRequired
        extends StatusCode(411) {}
shared object httpPreconditionFailed
        extends StatusCode(412) {}
shared object httpRequestEntityTooLarge
        extends StatusCode(413) {}
shared object httpRequestUriTooLong
        extends StatusCode(414) {}
shared object httpUnsupportedMediaType
        extends StatusCode(415) {}
shared object httpRequestedRangeNotSatisfiable
        extends StatusCode(416) {}
shared object httpExpectationFailed
        extends StatusCode(417) {}
shared object httpIAmATeapot
        extends StatusCode(418) {}
shared object httpUnprocessableEntity
        extends StatusCode(422) {}
shared object httpLocked
        extends StatusCode(423) {}
shared object httpFailedDependency
        extends StatusCode(424) {}
shared object httpReservedForWebdavAdvancedCollectionsExpiredProposal
        extends StatusCode(425) {}
shared object httpUpgradeRequired
        extends StatusCode(426) {}
shared object httpPreconditionRequired
        extends StatusCode(428) {}
shared object httpTooManyRequests
        extends StatusCode(429) {}
shared object httpRequestHeaderFieldsTooLarge
        extends StatusCode(431) {}

shared object httpInternalServerError
        extends StatusCode(500) {}
shared object httpNotImplemented
        extends StatusCode(501) {}
shared object httpBadGateway
        extends StatusCode(502) {}
shared object httpServiceUnavailable
        extends StatusCode(503) {}
shared object httpGatewayTimeout
        extends StatusCode(504) {}
shared object httpVersionNotSupported
        extends StatusCode(505) {}
shared object httpVariantAlsoNegotiatesExerimental
        extends StatusCode(506) {}
shared object httpInsufficientStorage
        extends StatusCode(507) {}
shared object httpLoopDetected
        extends StatusCode(508) {}
shared object httpNotExtended
        extends StatusCode(510) {}
shared object httpNetworkAuthenticationRequired
        extends StatusCode(511) {}

shared String? statusText(StatusCode code)
{
    return statusTextMap.get(code.code);
}

Map<Integer,String> statusTextMap = TreeMap((Integer x, Integer y) => x.compare(y), {
    100 -> "Continue",
    101 -> "Switching Protocols",
    102 -> "Processing",            // RFC2518
    200 -> "OK",
    201 -> "Created",
    202 -> "Accepted",
    203 -> "Non-Authoritative Information",
    204 -> "No Content",
    205 -> "Reset Content",
    206 -> "Partial Content",
    207 -> "Multi-Status",          // RFC4918
    208 -> "Already Reported",      // RFC5842
    226 -> "IM Used",               // RFC3229
    300 -> "Multiple Choices",
    301 -> "Moved Permanently",
    302 -> "Found",
    303 -> "See Other",
    304 -> "Not Modified",
    305 -> "Use Proxy",
    306 -> "Reserved",
    307 -> "Temporary Redirect",
    308 -> "Permanent Redirect",    // RFC-reschke-http-status-308-07
    400 -> "Bad Request",
    401 -> "Unauthorized",
    402 -> "Payment Required",
    403 -> "Forbidden",
    404 -> "Not Found",
    405 -> "Method Not Allowed",
    406 -> "Not Acceptable",
    407 -> "Proxy Authentication Required",
    408 -> "Request Timeout",
    409 -> "Conflict",
    410 -> "Gone",
    411 -> "Length Required",
    412 -> "Precondition Failed",
    413 -> "Request Entity Too Large",
    414 -> "Request-URI Too Long",
    415 -> "Unsupported Media Type",
    416 -> "Requested Range Not Satisfiable",
    417 -> "Expectation Failed",
    418 -> "I\"m a teapot",                                               // RFC2324
    422 -> "Unprocessable Entity",                                        // RFC4918
    423 -> "Locked",                                                      // RFC4918
    424 -> "Failed Dependency",                                           // RFC4918
    425 -> "Reserved for WebDAV advanced collections expired proposal",   // RFC2817
    426 -> "Upgrade Required",                                            // RFC2817
    428 -> "Precondition Required",                                       // RFC6585
    429 -> "Too Many Requests",                                           // RFC6585
    431 -> "Request Header Fields Too Large",                             // RFC6585
    500 -> "Internal Server Error",
    501 -> "Not Implemented",
    502 -> "Bad Gateway",
    503 -> "Service Unavailable",
    504 -> "Gateway Timeout",
    505 -> "HTTP Version Not Supported",
    506 -> "Variant Also Negotiates (Experimental)",                      // RFC2295
    507 -> "Insufficient Storage",                                        // RFC4918
    508 -> "Loop Detected",                                               // RFC5842
    510 -> "Not Extended",                                                // RFC2774
    511 -> "Network Authentication Required"                              // RFC6585
});
