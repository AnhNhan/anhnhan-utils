/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared alias CsrfTokenId => String;
shared alias CsrfTokenValue => String;

"A function or delegate that generates secure token values."
shared alias CsrfTokenValueGenerator => CsrfTokenValue();

by("Symfony Project")
shared class CsrfToken(shared CsrfTokenId id, shared CsrfTokenValue val)
{
}

"Responsible for persisting and retrieving csrf tokens."
by("Symfony Project")
shared interface CsrfTokenStorageInterface
{
    shared formal CsrfToken? retrieveToken(CsrfTokenId id);
    shared formal Boolean saveToken(CsrfToken token);
    shared formal Boolean removeToken(CsrfTokenId id);
    shared formal Boolean hasToken(CsrfTokenId id);
}

shared CsrfTokenValue uriSafeTokenTransformer(CsrfTokenValueGenerator valgen)
        => valgen().replace("+", "-").replace("/", "_").trimTrailing('='.equals);

"Manages CSRF Tokens from a context, e.g. a storage."
by("Symfony Project")
shared interface CsrfTokenManagerInterface
{
    """Retrieves a token with the given id from storage.

       If no token for the given id exists, a new one will be generated.
       Otherwise the existing token will be returned (not necessarily the same
       instance, though).
       """
    shared formal CsrfToken retrieveToken(CsrfTokenId id);

    """Generates a new token for the given id.

       This will happen regardless of whether a token already exists
       for the given id.

       The new token is returned.
       """
    shared formal CsrfToken  refreshToken(CsrfTokenId id);

    """Removes a token for a given id.

       Returns true if a token was deleted.
       """
    shared formal Boolean removeToken(CsrfTokenId id);

    "Whether a given token is valid."
    shared formal Boolean isTokenValid(CsrfToken token);
}

by("Symfony Project")
see(`interface CsrfTokenManagerInterface`)
shared class CsrfTokenManager(CsrfTokenValueGenerator generator, CsrfTokenStorageInterface storage)
    satisfies CsrfTokenManagerInterface
{
    shared actual Boolean isTokenValid(CsrfToken token)
    {
        value _token = storage.retrieveToken(token.id);
        if (exists _token)
        {
            return _token.val == token.val;
        }
        return false;
    }

    shared actual CsrfToken refreshToken(CsrfTokenId id) => generateAndSaveToken(id);

    shared actual Boolean removeToken(CsrfTokenId id) => storage.removeToken(id);

    shared actual CsrfToken retrieveToken(CsrfTokenId id) => storage.retrieveToken(id) else generateAndSaveToken(id);

    CsrfToken generateToken(CsrfTokenId id) => CsrfToken(id, generator());
    CsrfToken generateAndSaveToken(CsrfTokenId id)
    {
        value token = generateToken(id);
        storage.saveToken(token);
        return token;
    }
}
