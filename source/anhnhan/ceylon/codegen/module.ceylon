/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

"""Since Ceylon does not have facilities for generative programming (but
   some cool reflection/instrospection tools), Codegen contains several
   components and tools to facilitate code generation.

   Current plan: Have implementations of the various
   [[ceylon.language.meta.declaration::Declaration]] interfaces. Have those
   implementations provide AST/pseudo-AST from which we generate Ceylon code.
   """
module anhnhan.ceylon.codegen "1.0.0"
{
    import anhnhan.utils "0.1";
    shared import ceylon.collection "1.1.0";
}
