
# The pState Parser

## Parsing Labels

State and transition labels are strings of Unicode characters that need to be converted to objects representing their structure. Both the state label parser and the transition label parser read a label, analyze if it is correct according to the grammar, construct a representation, simplify the representation, and check certain well-formedness conditions, all in one pass. The grammar of labels is defined in two steps:

- one grammar defines the syntax symbols in terms of characters
- one grammar defines the syntax of labels in terms of symbols

The scanner conceptually takes a string and returns a sequence of symbols. It is implemented here as a procedure, `getSym()`, that is called by each parser whenever the parser needs the next symbol. Both parsers are a set of mutually recursive procedures according to the technique of recursive descent parsing with one symbol lookahead. The scanner and some parsing procedures are shared by both parsers.

### Scanning Labels

A _symbol_ is either an integer literal, a fraction literal, an exponent literal, an identifier, or an operator.

- An integer literal is a (non-empty) sequence of digits `0`, ..., `9`
- A fraction literal is a (non-empty) sequence of digits with possibly a dot `.` at the beginning, in between, or end; a fraction literal may also be a Unicode vulgar fraction `½`, `⅓`, ...
- An exponent literal is a (non-empty) sequence of superscript digits `⁰`, ..., `⁹`, possibly preceded by a superscript minus `⁻`;
- An identifier may contain uppercase letters `A`, ..., `Z`, lowercase letter `a`, ..., `z`, digits, and subscripted digits `₀`, ..., `₉`, but must not start with a number. (For code generation purposes, identifiers may not contain an underscore `_`.)
- Operators are all mathematical symbols that can appear in types, expressions, statements, and labels.

Identifiers are used to name states, variables, constants, and events. Certain identifiers, like `if` and `max`, have a predetermined meaning and are treated differently by the parser, but are not treated differently by the scanner. The syntax of symbols is defined as:

    Symbol      ::=  Integer | Fraction | Exponent | Identifier | Operator | Keyword
    Integer     ::=  Digit {Digit}
    Fraction    ::=  Digit {Digit} [. {Digit}] | . Digit {Digit} |
                     ½ | ⅓ | ⅔ | ¼ | ¾ | ⅕ | ⅖ | ⅗ | ⅘ | ⅙ | ⅚ | ⅐ |
                     ⅛ | ⅜ | ⅝ | ⅞ | ⅑ | ⅒
    Exponent    ::=  [⁻] Supdigit {Supdigit}
    Identifier  ::=  Letter {Letter | Digit | Subdigit}
    Digit       ::=  0 | … | 9
    Supdigit    ::=  ⁰ | … | ⁹
    Subdigit    ::=  ₀ | … | ₉
    Operator    ::=  + | − | × | / | ∑ | ∏ | ( | ) | [ | ] | { | } |
                     # | ∈ | ∉ | ⊂ | ⊆ | ⊃ | ⊇ | ∩ | ∪ | \ |
                     ¬ | ∧ | ∨ | ≡ | ≢ | ⇒ | ⇐ |
                     = | ≠ | < | ≤ | > | ≥ |
                     . | ; | , | ? | : | $ | ^ | ┃ | ‥ | ∆ | @ | ≔ | ‖

A state or transition label is a sequence of symbols separated by spaces, tabs, and newline characters:

    Label  ::=  {[ Blank ] Symbol} {Blank}
    Blank  ::=  ' ' | '\t' | '\r' | '\n'

The principle of the longest match is used to resolve ambiguity: the character sequence `Algol60+ 7` is recognized as the identifier `Algol60`, operator `+`, integer `7`, rather than identifier `A`, identifier `l`, etc., or identifier `Algol`, integer `60`, operator `+`, etc.

Procedure `getSym()` scans the next symbol sets global variables `sym` and `val`. Variable `sym` becomes
  - `INT` when an integer is scanned; the value is in `val`,
  - `FRAC` when a fraction is scanned; the value is in `val`,
  - `EXP` when an exponent is scanned; the value is in `val`,
  - `IDENT` when an identifier is scanned; the value is in `val`,
  - a character of `operator` when an operator is scanned,
  - `None` when the end of the input is reached.

Procedure `getSym()` calls `getChar()` for assigning the next character of `src` to `ch`. At the end of the input, `getChar()` assigns `None` is assigned to `ch`.


```python
from fractions import Fraction
from unicodedata import digit

from pstate.core.core import *

INT = 1; FRAC = 2; EXP = 3; IDENT = 4

VULG = {'½': Fraction(1, 2), '⅓': Fraction(1, 3), '⅔': Fraction(2, 3),
        '¼': Fraction(1, 4), '¾': Fraction(3, 4), '⅕': Fraction(1, 5),
        '⅖': Fraction(2, 5), '⅗': Fraction(3, 5), '⅘': Fraction(4, 5),
        '⅙': Fraction(1, 6), '⅚': Fraction(5, 6), '⅐': Fraction(1, 7),
        '⅛': Fraction(1, 8), '⅜': Fraction(3, 8), '⅝': Fraction(5, 8),
        '⅞': Fraction(7, 8), '⅑': Fraction(1, 9), '⅒': Fraction(1, 10)}

SUPDIGIT = {'⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'}

SUBDIGIT = {'₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'}

OP = {'+', '-', '×', '/', '∑', '∏', '(', ')', '[', ']', '{', '}',
      '#', '∈', '∉', '⊆', '⊇', '⊂', '⊃', '∩', '∪', '\\',
      '¬', '∧', '∨', '≡', '≢', '⇒', '⇐',
      '=', '≠', '<', '≤', '>', '≥',
      '.', ';', ',', '?', ':', '×', '→', '$', '^', '|', '‥', '∆', '@', '≔', '‖'}

KW = {'in', 'bool', 'if', 'then', 'else', 'exp', 'unif', 'div', 'mod', 'true', 'false', 'set',
      'bool', 'min', 'max', 'all', 'any', 'some'}

def getChar():
    global pos, ch
    if pos < len(src): ch, pos = src[pos], pos + 1
    else: ch = chr(0)

# TODO identifiers temporarilly modified to allow '.' as a character: pretty-printing more readable
def getSym():
    global sym, val
    while ch in ' \t\r\n': getChar()
    if 'a' <= ch <= 'z' or 'A' <= ch <= 'Z':
        s = ch; getChar()
        while 'a' <= ch <= 'z' or 'A' <= ch <= 'Z' or '0' <= ch <= '9' or ch in SUBDIGIT or ch == '.':
            s += ch; getChar()
        if s in KW: sym = s
        else: sym, val = IDENT, s
    elif '0' <= ch <= '9':
        s = ch; getChar()
        while '0' <= ch <= '9': s += ch; getChar()
        if ch == '.':
            s += ch; getChar()
            while '0' <= ch <= '9': s += ch; getChar()
            sym, val = FRAC, Fraction(s)
        else: sym, val = INT, int(s)
    elif ch == '.':
        s = ch; getChar()
        if '0' <= ch <= '9':
            s += ch; getChar()
            while '0' <= ch <= '9':
                s += ch; getChar()
            sym, val = FRAC, Fraction(s)
        else: sym = '.'
    elif ch in VULG: sym, val = FRAC, VULG[ch]; getChar()
    elif ch in OP: sym = ch; getChar()
    elif ch in SUPDIGIT:
        sym, val = EXP, digit(ch); getChar()
        while ch in SUPDIGIT:
            val = 10 * val + digit(ch); getChar()
    elif ch == '⁻':
        getChar()
        if ch in SUPDIGIT:
            sym, val = EXP, digit(ch); getChar()
            while ch in SUPDIGIT:
                val = 10 * val + digit(ch); getChar()
            val = - val
        else: raise Error('Exponent missing')
    elif ch == chr(0): sym = None
    else: raise Error("Unexpected character '" + ch + "'")
```

TODO attempt to treat keywords as standard identifiers caused a problem with parsing Designator: with `div`, `mod` as identifiers, `a div 3` is parsed as `a(div)`; LL(1) condition no longer holds. Other solution?


```python
def testGetSym(s: str):
    global src, pos
    src, pos, res = s, 0, []; getChar(); getSym()
    while sym is not None:
        res.append((sym, val if sym in (INT, FRAC, EXP, IDENT) else '')); getSym()
    return res

assert testGetSym('<⅜882 S₃ qq33 +/ ⁻⁴⁷ if a.b .99') == [('<', ''), (FRAC, Fraction(3, 8)), (INT, 882),
    (IDENT, 'S₃'), (IDENT, 'qq33'), ('+', ''), ('/', ''), (EXP, -47), ('if', ''), (4, 'a.b'),
    (2, Fraction(99, 100))]
```

### Parsing Types

Abstractly, the syntax of chart types is:

    Type      ::=  bool | Subrange | Product | Function | Set
    Subrange  ::=  Expression ‥ Expression
    Product   ::=  Type {× Type}
    Function  ::=  Type → Type
    Set       ::=  set Type

The restrictions are:

- The lower and upper bound of subranges must be constant expressions and the subrange must not be empty.
- The domain of a function can be a subrange, `bool`, or product, but not a function or a product containing a function.
- The elements of sets can be boolean and enumerations but not products, functions, or sets
- The operator `×` binds tighter than `→`, so `t × u → v × w` is parsed as `[t × u] → [v × w]`.
- The operator `→` associates to the right, so `t → u → v` is parsed as `t → [u → v]`.
- The operator `set` binds tighter than `→` and `×`, so `set 0‥1 × 0‥1` is parsed as `[set 0‥1] × 0‥1`
- A product must have at least two components.

Brackets can be used in types, e.g. `t × [u → v]` and `[3 ‥ 9]`. (Parenthesis can also appear in subrange bound expressions, e.g. `(N + 1) ‥ 10`, which means that parenthesis cannot not be used for types with one symbol lookahead parsing, e.g. `(3 ‥ 9)`.)

For parsing, the following concrete syntax is used:

    Type  ::= Basic {'×' Basic} ['→' Type]
    Basic ::= ['set'] (bool | Expression '‥' Expression | '[' Type ']')

TODO allow sets of products, functions, and sets, still assuming a bitset implementation:
- `set [0..9 × 0..1]`: 20 members, bitset in one word of 32 bits
- `set [0..15 × 0..15]`: 256 members, bitset in 8 word of 32 bits
- `set [bool → bool]`: 4 members, bitset in 1 byte
- `set set 0..7`: has 256 = 2^8 members, bitset in 8 word of 32 bits

TODO allow functions as function arguments, to complete the analogy of sets as boolean-valued functions.


```python
def parseBasicType(s: State) -> Type:
    if sym == 'set': getSym(); st = True
    else: st = False
    if sym == 'bool': getSym(); t = Type('bool')
    elif sym in FirstExpression:
        lb = parseConditional(s)
        if type(lb) == Fraction and lb == int(lb): lb = int(lb)
        elif type(lb) != int: raise Error('Integer constant expected', s)
        if sym == '‥': getSym()
        else: raise Error('‥ expected', s)
        ub = parseConditional(s)
        if type(ub) == Fraction and ub == int(ub): ub = int(ub)
        elif type(ub) != int: raise Error('Integer constant expected', s)
        if lb > ub: raise Error('Lower bound must be less than upper bound', s)
        t = Type('‥', lb, ub)
    elif sym == '[':
        getSym(); t = parseType(s)
        if sym == ']': getSym()
        else: print(sym); raise Error('] expected')
    else: raise Error('Type expected', s)
    return Type('set', t) if st else t

def parseType(s: State) -> Type:
    t = [parseBasicType(s)]
    while sym == '×': getSym(); t.append(parseBasicType(s))
    t = t[0] if len(t) == 1 else Type('×', *t)
    if sym == '→': getSym(); u = parseType(s); return Type('→', t, u)
    else: return t

def testParseType(label: str) -> Type:
    global src, pos
    src, pos = label, 0; getChar(); getSym()
    return parseType('some state')

FirstExpression = set() # for the test cases below only
assert str(testParseType('bool×bool×bool  →  bool × bool')) == 'bool × bool × bool → bool × bool'
assert str(testParseType('bool → [bool → [bool × bool]]')) == 'bool → bool → bool × bool'
assert str(testParseType('set bool → bool → set [bool × bool]')) == 'set bool → bool → set [bool × bool]'
assert str(testParseType('bool × [bool → bool] × bool')) == 'bool × [bool → bool] × bool'
del FirstExpression
```

### Parsing Expressions

Abstractly, the syntax of expressions is:

    Expression     ::=  Integer | Fraction | true | false | Designator |
                        PrefixOp Expression | Expression PostfixOp |
                        Expression InfixOp Expression |
                        Expression ? Expression : Expression |
                        Comprehension | '{' [Expression] '}' | '(' Expression ')'
    Comprehension  ::=  Expression '|' Identifier ∈ Type [, Expression]
    Designator     ::=  Identifier {. Identifier} | Identifier Expression
    PrefixOp       ::=  - | ¬ | sum | prod | min | max | all | any | some | # | in
    PostfixOp      ::=  Exponent
    InfixOp        ::=  , | + | - | × | / | div | mod | ∧ | ∨ | ⇒ | ⇐ | '≡' | = | ≠ |
                        < | ≤ | > | ≥ | ∈ | ∉ | ⊆ | ⊇ | ⊂ | ⊃ | ∩ | ∪ | \ | ‥

The precedence of operators is:
- Enumeration `,`: lowest precedence
- Conditional `?` ... `:`
- Equivalence operators `⇒`, `⇐`, `≡`,
- Disjunction `∨`
- Conjunction `∧`
- Relational operators `=`, `≠`, `<`, `≤`, `>`, `≥`, `⊂`, `⊆`, `⊃`, `⊇`, `∈`, `∉`
- Additive operators `+`, `-`, `∪`
- Multiplicative operators `×`, `/`, `div`, `mod`, `∩`, `\`
- Prefix operators `-`, `¬`, `∑`, `∏`, `min`, `max`, `all`, `any`, `some`, `#`, `in`
- Exponent
- Function application
- Qualification `.`: highest precedence

For example, `A ∪ B = C ∧ x ∈ A ⇒ b` is parsed as `(((A ∪ B) = C) ∧ (x ∈ A)) ⇒ b`. Furthermore:
- Conditionals associate to the right, i.e. `a ? b : c ? d : e` is parsed as `a ? b : (c ? d : e)`
- Equivalence operators do not associate, i.e. `a ⇒ b ⇒ c` is syntactically incorrect
- Relational operators can be chained, i.e. `a ≤ b < c` means `a ≤ b ∧ b < c`
- Prefix operators associate to the right, i.e. `- max a` is parsed as `- (max a)`

The following syntax is used for parsing:

    Expression     ::=  Comprehension {',' Comprehension}
    Comprehension  ::=  Conditional ['|' Identifier '∈' Type [',' Conditional]]
    Conditional    ::=  Equivalence [? Equivalence : Conditional]
    Equivalence    ::=  Disjunction [(≡ | ≢ | ⇒ | ⇐ ) Disjunction]
    Disjunction    ::=  Conjunction {∨ Conjunction}
    Conjunction    ::=  Relational {∧ Relational}
    Relational     ::=  Arithmetic {(= | ≠ | < | ≤ | > | ≥ | ⊂ | ⊆ | ⊃ | ⊇ | ∈ | ∉) Arithmetic}
    Arithmetic     ::=  Term {(+ | - | ∪) Term}
    Term           ::=  Factor {(× | / | div | mod | ∩ | \) Factor}
    Factor         ::=  (-, ¬, ∑, ∏, min, max, all, any, some, #, in) Factor | Base [Exponent]
    Base           ::=  true | false | Integer | Fraction | Designator | '{' [Expression] '}' |
                        '(' Expression ')'
    Designator     ::=  Identifier {. Identifier} [Expression]


```python
FirstExpression = PrefixOp | {INT, FRAC, IDENT, '{', '('}
PrefixOp = {'⊖', '¬', '#', 'in', 'min', 'max', 'all', 'any', 'some', '∑', '∏', 'set'}
NonAssocCommOp = {',', '-', '/', 'div', 'mod', '⇒', '⇐', '≡', '≢', '=', '≠', '≤', '≥', '<', '>',
                  '∈', '∉', '⊆', '⊇', '⊂', '⊃', '\\', '‥'}

def parseExpression(s: State) -> Expression:
    e = parseComprehension(s)
    if sym == ',':
        e = [e]
        while sym == ',':
            getSym(); e.append(parseExpression(s))
        e = Application(',', e)
    return e

def parseComprehension(s: State) -> Expression:
    e = parseConditional(s)
    if sym == '|':
        getSym()
        if sym == IDENT: i = val; getSym()
        else: raise Error('identifier expected', s)
        if sym == '∈': getSym()
        else: raise Error('∈ expected', s)
        r = parseType(s)
        if r.kind != Kind.SUBRANGE: raise Error('subrange type expected')
        if sym == ',': getSym(); b = parseConditional(s)
        else: b = True
        e = abstraction(i, r, b, e)
    return e

def parseConditional(s: State) -> Expression:
    e = parseEquivalence(s)
    if sym == '?':
        getSym(); f = parseEquivalence(s)
        if sym == ':': getSym()
        else: raise Error(': expected', s)
        e = conditional(e, f, parseConditional(s))
    return e

def parseEquivalence(s: State) -> Expression:
    e = parseDisjunction(s)
    if sym in {'≡', '≢', '⇒', '⇐'}:
        op = sym; getSym(); f = parseDisjunction(s)
        if op == '≡': e = equality(e, f)
        elif op == '≢': e = disequality(e, f)
        elif op == '⇒': e = implication(e, f)
        else: e = consequence(e, f)
    return e

def parseDisjunction(s: State) -> Expression:
    e = parseConjunction(s)
    while sym == '∨':
        getSym(); e = disjunction(e, parseConjunction(s))
    return e

def parseConjunction(s: State) -> Expression:
    e = parseRelational(s)
    while sym == '∧':
        getSym(); e = conjunction(e, parseRelational(s))
    return e

def parseRelational(s: State) -> Expression:
    e = parseArithmetic(s)
    if sym in {'=', '≠', '<', '≤', '>', '≥', '⊂', '⊆', '⊃', '⊇', '∈', '∉'}:
        p, e = e, True
        while sym in {'=', '≠', '<', '≤', '>', '≥', '⊂', '⊆', '⊃', '⊇', '∈', '∉'}:
            op = sym; getSym(); f = parseArithmetic(s)
            p = equality(p, f) if op == '=' else \
                disequality(p, f) if op == '≠' else \
                less(p, f) if op == '<' else \
                lessequal(p, f) if op == '≤' else \
                greater(p, f) if op == '>' else \
                greaterequal(p, f) if op == '≥' else \
                subset(p, f) if op == '⊂' else \
                subsetequal(p, f) if op == '⊆' else \
                superset(p, f) if op == '⊃' else \
                supersetequal(p, f) if op == '⊇' else \
                member(p, f) if op == '∈' else \
                notmember(p, f)
            e, p = conjunction(e, p), f
    return e

def parseArithmetic(s: State) -> Expression:
    e = parseTerm(s)
    while sym in {'+', '-', '∪'}:
        op = sym; getSym(); f = parseTerm(s)
        e = addition(e, f) if op == '+' else \
            subtraction(e, f) if op == '-' else \
            union(e, f)
    return e

def parseTerm(s: State) -> Expression:
    e = parseFactor(s)
    while sym in {'×', '/', '∩', 'div', 'mod', '\\'}:
        op = sym; getSym(); f = parseFactor(s)
        e = multiplication(e, f) if op == '×' else \
            fractionaldivision(e, f) if op == '/' else \
            integerdivision(e, f) if op == 'div' else \
            integermodulo(e, f) if op == 'mod' else \
            intersection(e, f) if op == '∩' else \
            difference(e, f)
    return e

def parseFactor(s: State) -> Expression:
    if sym in {'-', '¬', '∑', '∏', '#', 'min', 'max', 'all', 'any', 'some', 'in'}:
        op = sym; getSym(); e = parseFactor(s)
        e = negative(e) if op == '-' else \
            negation(e) if op == '¬' else \
            summation(e) if op == '∑' else \
            product(e) if op == '∏' else \
            minimum(e) if op == 'min' else \
            maximum(e) if op == 'max' else \
            universal(e) if op == 'all' else \
            existential(e) if op == 'any' else \
            some(e) if op == 'some' else \
            cardinality(e) if op == '#' else \
            statetest(e)
    else:
        e = parseBase(s)
        if sym == EXP: e = exponentiation(e, val); getSym()
    return e

def parseBase(s: State) -> Expression:
    if sym == 'true': getSym(); e = True
    elif sym == 'false': getSym(); e = False
    elif sym == INT: e = val; getSym()
    elif sym == FRAC: e = val; getSym()
    elif sym == IDENT: e = parseDesignator(s)
    elif sym == '{':
        getSym()
        if sym in FirstExpression:
            e = parseExpression(s)
        if sym == '}': getSym()
        else: raise Error('} expected')
    elif sym == '(':
        getSym(); e = parseExpression(s)
        if sym == ')': getSym()
        else: raise Error(') expected', s)
    else: raise Error('expression expected', 's')
    return e

def parseDesignator(s: State) -> Expression:
    """assumes sym == IDENT"""
    e = val; getSym()
#    e = [val]; getSym()
#    while sym == '.':
#        getSym()
#        if sym != IDENT: error('identifier expected', s)
#        e.append(val); getSym()
    if sym in FirstExpression:
        e = Application(e, parseExpression(s))
    return e
```

Following tests are for operator precedence and associativity.


```python
def testParseExpression(label: str) -> Expression:
    global src, pos
    src, pos = label, 0; getChar(); getSym();
    return parseExpression('some state')

assert str(testParseExpression('a + b | c ∈ 3 + 2 ‥ 5, d < e, f')) == 'c ∈ 5 ‥ 5, d < e • a + b, f'
assert str(testParseExpression('a ≢ b ? c ≡ d : e ⇒ f ∨ (g ⇐ h)')) == '(¬ (a = b) ? c = d : e ⇒ (f ∨ (h ⇒ g)))'
assert str(testParseExpression('a = b ∨ c ≠ d + 2 ∧ e < f ≤ g > h ≥ i ⇒ j ⊂ k ⊆ l ⊃ m ⊇ n ∧ o + p ∈ q ∉ r')) == \
'(((a = b) ∨ (¬ (c = (2 + d)) ∧ (e < f) ∧ (f ≤ g) ∧ (g > h) ∧ (h ≥ i))) ⇒ \
((j ⊂ k) ∧ (k ⊆ l) ∧ (m ⊂ l) ∧ (n ⊆ m) ∧ ((o + p) ∈ q) ∧ ¬ (q ∈ r)))'
assert str(testParseExpression('a - b + c + d - e = f × g × h div 4 mod 4 × i × j')) == \
'((((a - b) + c + d) - e) = ((((f × g × h) div 4) mod 4) × i × j))'
assert str(testParseExpression('a ∪ b ∩ c ∪ d ⊆ e \\ f \\ g ∩ i ∩ j')) == \
'((a ∪ (b ∩ c) ∪ d) ⊆ (((e \\ f) \\ g) ∩ i ∩ j))'
assert str(testParseExpression('- a + ∑(b | b ∈ 4 ‥ 5) - ∏(c × d | c ∈ 6 ‥ 7) - some e')) == \
'(((- a + ∑ (b ∈ 4 ‥ 5 • b)) - ∏ (c ∈ 6 ‥ 7 • c × d)) - some e)'
```

### Parsing Statements

The grammar of chart statements defines `‖` to bind looser than `if-then-else` and allows statements to be grouped in parenthesis:

    Statement   ::=  Primary {‖ Primary}
    Primary     ::=  Assignment | Broadcast | CondStat | '(' Statement ')'
    Assignment  ::=  Designator {',' Designator} ≔ Expression
    CondStat    ::=  if Expression then Primary [else Primary]
    Broadcast   ::=  # Identifier

The grammar requires that nested `if-then-else` must be parenthesized, as in `if b then (if c then s) else t`.

TODO remove # for BroadCast


```python
# TODO proper compatibility check with nested types, type and subrange checks

def checkCompatibility(d: Expression, e: Expression): pass
    #if isinstance(d, Application) and d.fn == ',':
    #    for di in d.arg
    #if len(d) < len(e): raise Error('too few expressions on right hand side', s)
    #elif len(d) > len(e): raise Error('too many expression on right hand side', s)

def parseStatement(s) -> Statement:
    sl = [parsePrimary(s)]
    while sym == '‖' or sym == '∥': getSym(); sl.append(parsePrimary(s))
    return parallel(*sl)

def parsePrimary(s):
    if sym == IDENT: # assignment
        d = parseDesignator(s)
        if sym == ',':
            d = [d]
            while sym == ',':
                getSym(); d.append(parseDesignator(s))
            d = Application(',', d)
        if sym == '≔': getSym()
        else: raise Error('≔ expected', s)
        e = parseExpression(s)
        checkCompatibility(d, e)
        stat = Assignment(d, e)
    elif sym == '#':
        getSym()
        if sym == IDENT: stat = val; getSym()
        else: raise Error('event name expected', s)
    elif sym == 'if':
        getSym(); cond = parseExpression(s)
        if sym != 'then': raise Error('then expected', s)
        getSym(); thn = parsePrimary(s)
        if sym == 'else': getSym(); stat = CondStat(cond, thn, parsePrimary(s))
        else: stat = CondStat(cond, thn)
    elif sym == '(':
        getSym(); stat = parseStatement(s)
        if sym == ')': getSym()
        else: raise Error(') expected', s)
    else: raise Error('not a statement', s)
    return stat
```


```python
def testParseStatement(label: str) -> Expression:
    global src, pos
    src, pos = label, 0; getChar(); getSym();
    return str(parseStatement('some state'))

assert testParseStatement('if 1/10 < a then a, b ≔ b + 2, min c') == 'if 1/10 < a then a, b ≔ 2 + b, min c'
assert testParseStatement('if - # a ≥ 2 then (#b ‖ a ≔ true) else #c ‖ d, e ≔ f') == \
    '(if - # a ≥ 2 then (b ∥ a ≔ True) else c ∥ d, e ≔ f)'
assert testParseStatement('a ≔ b ‖ (c ≔ d ‖ e ≔ f)') == '(a ≔ b ∥ c ≔ d ∥ e ≔ f)'
```

    x := a filter (x • x mod 2 = 0) map (x • x + 2) reduce (x, y • x × y)
    x := a filter (x mod 2 = 0 | x) map (x • x + 2) reduce (x, y • x × y)

    c := (a zip b) map (_0 = _1) reduce (_0 & _1)
    x := a filter (# mod 2 = 0) // filter all with even index

    x := a filter (_ mod 2 = 0) map (_ + 2) reduce (_0 * _1)
    c := (a zip b) map (_0 = _1) reduce (_0 & _1)
    x := a filter (# mod 2 = 0) // filter all with even index

- All children of a state must have unique names. Capitalization is significant and any two children of a state must differ more than in just the capitalization.


### Parsing State Labels

- A child state may have the same name as its parent or any ancestor, but the names of all siblings must differ more than just by capitalization. For example, `X1` and `x1` cannot be children of the same parent, but `X1` and `X2` can. Children of distinct parents can have the same name.
- Variables and constants declared in a state must have names unique among all variables and constants of that state. Variables declared in different states may have the same name, also if one state is the descendant of another.
- The variable names declared in a state must differ from the names of all children of that state by more than just capitalization. For example, `X1` and `x1` cannot be the name of a variable and a child of state, but `X1` and `X2` can.


    StateLabel      ::=  [Identifier {; (Var | Const)}] ['|' Expression] {$ Cost / TimeUnit | ^ Event}
    Event           ::=  Identifier
    Const           ::=  IdentifierList = Expression
    Var             ::=  IdentifierList : Type
    IdentifierList  ::=  Identifier {',' Identifier}
    Cost            ::=  Identifier = Expression [Unit]
    Unit            ::=  [UnitPrefix] Identifier
    TimeUnit        ::=  [TimeUnitPrefix] s | min | h | d
    UnitPrefix      ::=  E | P | T | G | M | k | h | da | d | c | m | µ | n | p | f | a
    TimeUnitPrefix  ::=  m | µ | n | p | f | a


> TODO add units to constants, variables, make units more fancy, with proper checking and conversion:
>
> `Unit ::= [prefix] identifier [exponent] {("." | "/" [prefix] identifier [exponent]}`

Cost expressions may refer to variables and states. Examples: TODO

The prefixes are according to https://en.wikipedia.org/wiki/Metric_prefix. The time units are non-SI units accepted for use with SI units, http://www.bipm.org/en/publications/si-brochure/table6.html. Prefixes and units are not keywords, meaning them above identifiers can also be used for event and state names. The prefix does not need to be separated from the time unit.


```python
UnitPrefix = {'E': Fraction(100000000, 1), 'P': Fraction(10000000, 1),
              'T': Fraction(1000000, 1), 'G': Fraction(100000, 1), 'M': Fraction(10000, 1),
              'k': Fraction(1000, 1), 'h': Fraction(100, 1), 'da': Fraction(10, 1),
              'd': Fraction(1, 10), 'c': Fraction(1, 100), 'm': Fraction(1, 1000),
              'µ': Fraction(1, 10000), 'n': Fraction(1, 100000), 'p': Fraction(1, 1000000),
              'f': Fraction(1, 10000000), 'a': Fraction(1, 100000000)}

TimeUnit = {'s': 1, 'min': 60, 'h': 3600, 'd': 86400}

TimeUnitPrefix = {'m': Fraction(1, 1000), 'µ': Fraction(1, 10000), 'n': Fraction(1, 100000),
                  'p': Fraction(1, 1000000), 'f': Fraction(1, 10000000), 'a': Fraction(1, 100000000)}

FirstTimeUnit = set(TimeUnitPrefix.keys()) | set(TimeUnit.keys())

def parseStateLabel(label: str, s: State):
    # assumes that s.name, s.const, s.var, s.ev, s.inv, s.cost are freshly initialized
    global src, pos
    src, pos = label, 0; getChar(); getSym()
    if sym == IDENT: # check if names of all siblings differ by more than capitalization
        if s.parent is None or all(c.name.lower() != val.lower() for c in s.parent.children - {s}):
            s.name = val; getSym()
        else:
            print('parseStateLabel', s.parent.children, val)
            raise Error('Sibling state has same or similar name', s)
        while sym == ';':
            getSym(); ids = parseIdentifierList(s)
            if sym == '=': # constant declaration
                getSym(); e = parseExpression(s)
                if isinstance(e, (int, Fraction)):
                    for i in ids:
                        if i not in s.const and i not in s.var: s.const[i] = e
                        else: raise Error('Duplicate name', s)
                else: raise Error('Constant expected', s)
            elif sym == ':':
                getSym(); tp = parseType(s)
                for i in ids:
                    if i not in s.const and i not in s.var: s.var[i] = tp
                    else: raise Error('Duplicate name', s)
            else: raise Error('Constant or variable declaration expected', s)
        if any(v.lower() == c.name.lower() for v in s.var for c in s.children):
            raise Error('Child state has same or similar name as variable', s)
    if sym == '|': getSym(); s.inv = parseExpression(s)
    while sym == '$' or sym == '^': # {Cost / Timeunit | Event}
        if sym == '$':
            getSym(); ci, ce, cp, cu = parseCost(s) # cost identifier, expression, prefix, unit
            if sym == '/': getSym()
            else: raise Error('/ expected', s)
            ctu = parseTimeUnit(s) # cost time unit relative to sec
            if ci not in s.cost: s.cost[ci] = (cp * ce / ctu, cu) # normalize cost
            else: raise Error('Duplicate cost name', s)
        else:
            getSym(); ids = parseIdentifierList(s)
            if set(ids) & s.ev == set(): s.ev.update(set(ids))
            else: raise Error('Duplicate event name', s)

# returns identifier, expression, prefix, unit
def parseCost(s: State) -> Tuple[Text, Expression, ConstNumberExpression, Optional[Text]]:
    if sym != IDENT: raise Error('Identifier expected', s)
    i = val; getSym()
    if sym != '=': raise Error('= expected', s)
    getSym(); e = parseExpression(s)
    if sym == IDENT:
        if val in UnitPrefix:
            p = UnitPrefix[val]; getSym(); u = val
            if sym != IDENT: raise Error('Unit expected', s)
        elif val[0:1] in UnitPrefix: p, u = UnitPrefix[val[0:1]], val[1:]
        elif val[0:2] in UnitPrefix: p, u = UnitPrefix[val[0:2]], val[2:]
        else: p, u = 1, val
        getSym()
    else: p, u = 1, None
    return i, e, p, u

def parseIdentifierList(s: State) -> Sequence[str]:
    if sym != IDENT: raise Error('Identifier expected', s)
    ids = [val]; getSym()
    while sym == ',':
        getSym()
        if sym != IDENT: raise Error('Identifier expected', s)
        elif val in ids: raise Error("Duplicate '" + val + "'", s)
        else: getSym(); ids.append(val)
    return ids

def parseTimeUnit(s) -> ConstNumberExpression:
    if sym == IDENT:
        if val in TimeUnitPrefix:
            p = TimeUnitPrefix[val]; getSym(); v = val
            if sym != IDENT: raise Error('Time unit expected', s)
        elif val[0:1] in TimeUnitPrefix: p, v = TimeUnitPrefix[val[0:1]], val[1:]
        elif val[0:2] in TimeUnitPrefix: p, v = TimeUnitPrefix[val[0:2]], val[2:]
        else: p, v = 1, val
        getSym()
    else: raise Error('Time unit expected', s)
    if v in TimeUnit: u = TimeUnit[v]
    else: raise Error('Improper time unit', s)
    return p * u
```


```python
def testParseStateLabel(label: str) -> State:
    global src, pos
    src, pos = label, 0; getChar(); getSym()
    s = State('dummy', None); s.name = None
    parseStateLabel(label, s)
    return s


s = testParseStateLabel('Working; S = 9; jobs: 0 ‥ 9 | jobs mod 2 = 0 ^Off  $power = .5mW/ms')
assert s.name == 'Working'; assert s.const == {'S': 9}; assert s.var == {'jobs': Type(Kind.SUBRANGE, 0, 9)}
assert s.inv == equality(integermodulo('jobs', 2), 0)
assert s.ev == {'Off'}; assert s.cost == {'power': (Fraction(1, 2), 'W')}

s = testParseStateLabel('Reading | readers>0 ∧ writers=0 $utility = 5units/s')
assert s.name == 'Reading'; assert s.inv == conjunction(greater('readers', 0), equality('writers', 0))
assert s.cost == {'utility': (5, 'units')}

# TODO '$power = .5W/min' not parsed as 'min' is recognized as a keyword
# TODO '$utility = 5/s' assigns expression 5/s to utility and does not recognize time units
# TODO '$cost = 1cent/s' assigns 1/100 ent to cost
```

### Parsing Connection Labels

    ConnectionLabel  ::=  [Identifier | Timing] {$ Cost} [∆ Time] ['[' Expression ']']
                          [@ Expression] [/ Statement]
    Timing           ::=  Time [‥ [Time]] | ‥ Time | exp '(' Time ')' | unif '(' Time , Time ')'
    Time             ::=  Expression [Timeunit]

Note that `exp` and `unif` are keywords, implying that they cannot be used as names of states or events.


```python
FirstTime = FirstExpression
FirstTiming = FirstTime | {'‥', 'exp', 'unif'}

class ConnectionLabel(NamedTuple):
    event: Optional[Union[Event, Timing]]
    costs: MutableMapping[Text, Cost]
    wcet: Optional[Expression]
    guard: Optional[Expression]
    prob: Optional[Expression]
    stat: Optional[Statement]

def parseConnectionLabel(label, cid) -> ConnectionLabel:
    global src, pos
    src, pos = label, 0; getChar(); getSym()
    if sym == IDENT: getSym(); kind = val
    elif sym in FirstTiming: kind = parseTiming(cid)
    else: kind = None
    cost = {}
    while sym == '$':
        getSym(); ci, ce, cp, cu = parseCost(cid) # cost identifier, expression, prefix, unit
        if ci not in cost: cost[ci] = (cp * ce, cu) # normalize cost
        else: raise Error('Duplicate cost name', s)
    if sym == '∆': getSym(); wcet = parseTime(cid)
    else: wcet = None
    if sym == '[':
        getSym(); guard = parseExpression(cid)
        if sym == ']': getSym()
        else: raise Error('] expected', cid)
    else: guard = None
    if sym == '@': getSym(); prob = parseExpression(cid)
    else: prob = None
    if sym == '/': getSym(); stat = parseStatement(cid)
    else: stat = skip
    return ConnectionLabel(kind, cost, wcet, guard, prob, stat)

def parseTiming(cid) -> Timing:
    if sym in FirstTime:
        t0 = parseTime(cid)
        if sym == '‥':
            getSym()
            if sym in FirstTime: t = Timing('between', t0, parseTime(cid))
            else: t = Timing('between', t0, None)
        else: t = Timing('between', t0, t0)
    elif sym == '‥':
        getSym(); t =  Timing('between', None, parseTime(cid))
    elif sym == 'exp':
        getSym()
        if sym != '(': raise Error('( expected', cid)
        getSym(); t = Timing('exp', parseTime(cid))
        if sym == ')': getSym()
        else: raise Error(') expected', cid)
    elif sym == 'unif':
        getSym()
        if sym != '(': raise Error('( expected', cid)
        getSym(); t0 = parseTime(cid)
        if sym != ',': raise Error(', expected', cid)
        getSym(); t = Timing('unif', t0, parseTime(cid))
        if sym == ')': getSym()
        else: raise Error(') expected', cid)
    return t

#TODO ask many places where parseExpression is used but a literal is required like here with *
def parseTime(cid):
    t = parseExpression(cid)
    if sym == IDENT: t = t * parseTimeUnit(cid)
    return t

def parseFirstConnectionLabel(label, cid):
    kind, cost, wcet, guard, prob, stat = parseConnectionLabel(label, cid)
    if prob is not None: raise Error('Probability not allowed', cid)
    if guard is None: guard = True
    return kind, guard, cost, stat

def parseProbConnectionLabel(label, cid):
    kind, cost, wcet, guard, prob, stat = parseConnectionLabel(label, cid)
    if kind is not None: raise Error('Event/time not allowed', cid)
    if guard is not None: raise Error('Guard not allowed', cid)
    if prob is None: prob = 1
    if cost != {}: raise Error('Cost not allowed', cid)
    return prob, stat

def parseCondConnectionLabel(label, cid):
    kind, cost, wcet, guard, prob, stat = parseConnectionLabel(label, cid)
    if kind is not None: raise Error('Event/time not allowed', cid)
    if guard is None: guard = True
    if prob is not None: raise Error('Probability not allowed', cid)
    if cost != {}: raise Error('Cost not allowed', cid)
    return guard, stat

# TODO process wcet
```


```python
assert parseConnectionLabel('Request $req = 7 unit [in Machine.Idle] / jobs ≔ 1 ‖ #WarmUp', 'some connection') == \
       ConnectionLabel(event='Request', costs={'req': (7, 'unit')}, wcet=None,
           guard=Application(fn='in', arg='Machine.Idle'), prob=None,
           stat=ParallelComp(elems=[Assignment(var='jobs', expr=1), 'WarmUp']))
assert parseConnectionLabel('StartReading ∆.1ms [writers=0] / readers ≔ 1', 'some connection') == \
       ConnectionLabel(event='StartReading', costs={}, wcet=Fraction(1, 10000),
           guard=Application(fn='=', arg=['writers', 0]), prob=None, stat=Assignment(var='readers', expr=1))
assert parseConnectionLabel('exp(10 ms) $cust = 1 @0.5', 'some connection') == \
       ConnectionLabel(event=Timing('exp', Fraction(1, 100)), costs={'cust': (1, None)}, wcet=None, guard=None,
           prob=Fraction(1, 2), stat=Skip())
```

## Alternative Implementations

#### Scanner as Iterator

- Avoids the use of global variables to preserve the state of the scanner; the scanner below can be made even more elegant by turning `getChar` into a coroutine of its own
- Reporting of error positions would require that the scanner "yields" both the symbol and its position, necessitating a use of the form `scan = scanner(src); ... sym, pos = next(scan)` (where `pos` is the position of `sym`, not the current position)
- Allows an elegant solution to superscripted exponents being viewed by the scanner as two symbols, an exponentiation symbol followed by the integer exponent
- Necessitates that the scanner is passed around as a parameter to all parsing procedures

```
INT = 1; FRAC = 2; EXP = 3; IDENT = 4

VULG = {'½': Fraction(1, 2), '⅓': Fraction(1, 3), '⅔': Fraction(2, 3),
        '¼': Fraction(1, 4), '¾': Fraction(3, 4), '⅕': Fraction(1, 5),
        '⅖': Fraction(2, 5), '⅗': Fraction(3, 5), '⅘': Fraction(4, 5),
        '⅙': Fraction(1, 6), '⅚': Fraction(5, 6), '⅐': Fraction(1, 7),
        '⅛': Fraction(1, 8), '⅜': Fraction(3, 8), '⅝': Fraction(5, 8),
        '⅞': Fraction(7, 8), '⅑': Fraction(1, 9), '⅒': Fraction(1, 10)}

SUPDIGIT = {'⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'}

SUBDIGIT = {'₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'}

OP = {'+', '-', '×', '/', '∑', '∏', '(', ')', '[', ']', '{', '}',
      '#', '∈', '∉', '⊆', '⊇', '⊂', '⊃', '∩', '∪', '\\',
      '¬', '∧', '∨', '≡', '≢', '⇒', '⇐',
      '=', '≠', '<', '≤', '>', '≥',
      '.', ';', ',', '?', ':', '×', '→', '$', '|', '‥', '∆', '@', '≔', '‖'}

KW = {'in', 'bool', 'set', 'if', 'then', 'else', 'exp', 'unif', 'div', 'mod',
      'true', 'false', 'min', 'max', 'all', 'any', 'some'}

# TODO identifiers temporarilly modified to allow '.' as a character: pretty-printing more readable

def symbols(src: str) -> Iterator[Union[int, Fraction, str, None]]:
    pos: int; ch: str
    def getChar():
        nonlocal src, ch, pos
        if pos < len(src): ch, pos = src[pos], pos + 1
        else: ch = chr(0)
    pos = 0; getChar()
    while ch != chr(0):
        while ch in ' \t\r\n': getChar()
        if 'a' <= ch <= 'z' or 'A' <= ch <= 'Z':
            s = ch; getChar()
            while 'a' <= ch <= 'z' or 'A' <= ch <= 'Z' or '0' <= ch <= '9' or ch in SUBDIGIT or ch == '.':
                s += ch; getChar()
            yield s
        elif '0' <= ch <= '9':
            s = ch; getChar()
            while '0' <= ch <= '9': s += ch; getChar()
            if ch == '.':
                s += ch; getChar()
                while '0' <= ch <= '9': s += ch; getChar()
                yield Fraction(s)
            else: yield int(s)
        elif ch == '.':
            s = ch; getChar()
            if '0' <= ch <= '9':
                s += ch; getChar()
                while '0' <= ch <= '9':
                    s += ch; getChar()
                yield Fraction(s)
            else: yield '.'
        elif ch in VULG: yield VULG[ch]; getChar()
        elif ch in OP: yield ch; getChar()
        elif ch in SUPDIGIT:
            sym, val = EXP, digit(ch); getChar()
            while ch in SUPDIGIT:
                val = 10 * val + digit(ch); getChar()
            yield '^'; yield val
        elif ch == '⁻':
            getChar()
            if ch in SUPDIGIT:
                sym, val = EXP, digit(ch); getChar()
                while ch in SUPDIGIT:
                    val = 10 * val + digit(ch); getChar()
                yield '^'; yield  - val
            else: raise Error('Exponent missing')
        elif ch == chr(0): yield None
        else: raise Error("Unexpected character '" + ch + "'")
    yield None
```

```
assert list(symbols('<⅜882 S₃ qq33 +/ ⁻⁴⁷ if a.b .99')) == \
    ['<', Fraction(3, 8), 882, 'S₃', 'qq33', '+', '/', '^', -47, 'if', 'a.b', Fraction(99, 100), None]
```
