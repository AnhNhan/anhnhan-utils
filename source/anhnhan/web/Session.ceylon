/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    MutableMap
}

shared interface Session
    satisfies MutableMap<String, String>
{
    shared formal String? id;
    shared formal String? name;

    "Starts a session."
    shared formal Boolean start();
    "Checks whether the session was started."
    shared formal Boolean isStarted();

    "Invalidates the current session.

     Deletes all data both here and from storage, and spawns a new session
     with the given lifetime."
    shared formal Boolean invalidate(
        "The lifetime of the new session. [[null]] sets it to the
         system default. 0 will expire the session with the browser session.

         Time is an offset/TTL in seconds, and not a Unix timestamp."
        Integer? lifetime = null
    );

    "Migrates the session to a new session (with a new id), while maintaining
     all attributes."
    shared formal Boolean migrate(
        "Whether to destroy the old session"
        Boolean destroy = false,
        "The lifetime of the new session. [[null]] sets it to the
         system default. 0 will expire the session with the browser session.

         Time is an offset/TTL in seconds, and not a Unix timestamp."
        Integer? lifetime = null
    );

    shared formal void save();
}
