/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
interface Renderable
{
    "Generates a string representation of this AST element in a generic
     context."
    shared formal
    String render();

    "Renders this AST element in an statement context. This is especially useful
     for expressions, which need to be special cased in such a context."
    shared
    String renderAsStatement()
    {
        value _this = this;
        if (is Expression _this)
        {
            return render() + ";";
        }
        // Yeah, stuff like function definition parameter and names. We only
        // want to special case expressions themselves, though. And it's not
        // like these can be rendered in a statement context.
        return render();
    }
}
