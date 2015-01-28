/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

"""The package `anhnhan.parser.parsec` may contain some cool stuff for parsing
   stuff, but if you ask yourself what it would be actually useful stuff,
   answering with "parsing stuff" is actually not-quite on the point. There are
   a few problems we can solve / questions we can answer with the parsec lib,
   but it's not useful for full-fledged parsing yet.

   What it can do for you now:

     * construct a parser, that can:
     * tell you whether a given input can be successfully matched with the
       constructed parser
     * give you the exact relevant matches

   It can not do:

     * tell you what had been matched, how it came to that conlusion or where it
       came from

   Enter the `anhnhan.parser.parsec.tree` package.
   """
shared package anhnhan.parser.tree;
