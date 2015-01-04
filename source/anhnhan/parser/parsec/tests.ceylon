/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.parser.parsec.string {
    skipWhitespace,
    whitespace
}

import ceylon.test {
    test,
    assertEquals,
    fail
}

test
void test0001()
{
    value str1 = "a b c d";
    value parser1 = sequence<Character|Anything[], Character>(literal('a'), skipWhitespace, skip(literal('b')), literal(' '));

    value result1 = parser1(str1);
    assertEquals(result1, ok(['a', [], [], ' '], "c d"));

    value filtered1 = filterEmpty<Character|Anything[], Character>(result1);
    bind<Character|Anything[], Character, Anything, Anything> {
        (Ok<Character|Anything[], Character> ok) => assertEquals(result(ok), ['a', ' ']);
        (Anything error) => fail();
    } (filtered1);
}

test
void test0002()
{
    value a_int = 'a'.integer;
    value str = ['a'];
    value ints = [a_int];
    value charParser = literal('a');
    value intParser = literal<Integer>(a_int);

    value result1 = apply<Character, Character, Integer>(charParser, Character.integer)(str);
    value result2 = intParser(ints);

    assertEquals(result1, result2);
}

test
void test0003()
{
    value str = "foo";
    value _parse = or<Character, Character, Character>(literal('f'), literal('o'));
    value parse = oneOrMore<Character, Character>(_parse);

    assertEquals(parse(str), ok(['f', 'o', 'o'], ""));
}

test
void test0004()
{
    value str = "abc";
    value parse = and<Character, [Character, Character], Character>(
        literal('a'),
        and<Character, Character, Character>(
            literal('b'),
            literal('c')
        )
    );

    assertEquals(parse(str), ok(['a', ['b', 'c']], ""));
}

test
void test0005()
{
    value str1 = "abc def\n";
    value parse = sequence<Character[], Character>(manySatisfy(Character.letter), lookahead<Character, Character>(satisfy(Character.whitespace)));

    value pass1 = parse(str1);
    assert(is Ok<Character[][], Character> pass1);
    assertEquals(pass1, ok([['a', 'b', 'c'], []], " def\n"));

    value str2 = rest(whitespace(rest(pass1)));
    value pass2 = parse(str2);
    assert(is Ok<Character[][], Character> pass2);
    assertEquals(pass2, ok([['d', 'e', 'f'], []], "\n"));

    value str3 = rest(pass2);
    value pass3 = negativeLookahead<Character, Character>(whitespace)(str3);
    assert(is Error<Character[], Character> pass3);
    assertEquals(rest(pass3), "\n");

    value pass4 = lookahead<Character, Character>(whitespace)(str3);
    assert(is Ok<Character[], Character> pass4);
    assertEquals(rest(pass4), "\n");
}

test
void test0006()
{
    assert(nonempty fooStr = "foo".sequence());
    value fooP = literals(fooStr);
    value str1 = "foo    foo-foo";
    value parse1 = sequence<Character[], Character>(fooP, manySatisfy(Character.whitespace), fooP);

    value result1 = fooP(str1);
    assert(is Ok<Character[], Character> result1);
    assertEquals(result(result1), ['f', 'o', 'o']);

    value result2 = parse1(str1);
    assert(is Ok<Character[][], Character> result2);
    assertEquals(result(result2), [['f', 'o', 'o'], [' ', ' ', ' ', ' '], ['f', 'o', 'o']]);
}
