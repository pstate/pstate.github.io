

```python
from fractions import Fraction
from typing import TypeVar, Mapping, Sequence, Text

from pstate.core.core import Expression, disequality, Application, implication, negation, conjunction, Abstraction, \
    abstraction, summation, greater, integerdivision, Type, maximum, addition, Statement, skip, Assignment, GuardedComp, \
    ProbComp, simplification, subtraction, greaterequal, GuardedCompElem, disjunction, lessequal, equality, negative, \
    parallel, prob, guarded
from pstate.core.intermediate import accumulatedInvariant, goto, test
```

## Well-Formedness of Charts

All symbolic names need to be resolved according to the scoping rules

- expressions and assignments are properly typed
- probabilities must be non-negative constants and sum up to one
- all broadcasts are well-defined and broadcasting is not cyclic
- all state tests are well-defined
- parallel assignments, including those resulting from broadcasting, are conflict-free


```python
def checkCompleteDisjoint(conds, sid):  # returns list with message referring to state sid if check fails
    return []
```


```python
def checkProbsSumToOne(alts, sid):  # returns list with message referring to state sid if check fails
    return []
```

## Well-Definedness of Transition Expressions

Transition expressions are those that can appear in transition guards and bodies: all chart expressions except the binary operations `≡`, `⇒`, and `⇐`. The definedness `∆e` of expression `e` is determined as follows:

| Expression                                | Definedness                         |
| :---------------------------------------- | :---------------------------------- |
| `0`, `1`, ...                             | `true`                              |
| `m.n`                                     | `true`                              |
| `true`, `false`                           | `true`                              |
| `x`, `S.x`, `T.S.x`                       | `true`                              |
| `a(e)`                                    | `∆e ∧ l ≤ e ≤ u` provided `a : l‥u` |
| `e, f, ...`                               | `∆e ∧ ∆f ∧ ...`                     |
| `- e`                                     | `∆e`                                |
| `¬ e`                                     | `∆e`                                |
| `min e`, `max e`                          | `∆e`                                |
| `all e`, `any e`                          | `∆e`                                |
| `some e`                                  | `∆e`                                |
| `∑ e `, ` ∏ e`, `# e`                     | `∆e`                                |
| `in S`, `in T.S`                          | `true`                              |
| `e + f`, `e − f`, `e × f`                 | `∆e ∧ ∆f`                           |
| `e / f`                                   | `∆e ∧ ∆f ∧ f ≠ 0`                   |
| `e div f`, `e mod f`                      | `∆e ∧ ∆f ∧ f ≠ 0`                   |
| `e ∧ f`, `e ∨ f`                          | `∆e ∧ ∆f`                           |
| `e = f`, `e ≠ f`                          | `∆e ∧ ∆f`                           |
| `e ≤ f`, `e ≥ f`, `e < f`, `e > f`        | `∆e ∧ ∆f`                           |
| `e ∈ f`, `e ∉ f`                          | `∆e ∧ ∆f`                           |
| `e ⊆ f`, `e ⊇ f`, `e ⊂ f`, `e ⊃ f`        | `∆e ∧ ∆f`                           |
| `e ∩ f`, `e ∪ f`, `e \ f`                 | `∆e ∧ ∆f`                           |
| `b ? e : f`                               | `∆b ∧ (b ⇒ ∆e) ∧ (¬b ⇒ ∆f)`         |
| `{e, f,` ...`}`                           | `∆e ∧ ∆f ∧` ...                     |
| `e ‥ f`                                   | `∆e ∧ ∆f`                           |
| `{e ∣ i ∈ r, b}`                          | `(all ∆b ∧ (b ⇒ ∆e) ∣ i ∈ r)`       |
| `∑ e ∣ i ∈ r, b`, &nbsp; `∏ e ∣ i ∈ r, b` | `(all ∆b ∧ (b ⇒ ∆e) ∣ i ∈ r)`       |

For example:

    ∆(∑ x div i > 2 | i ∈ 4 ‥ 7, i ≠ j)
    = ∆(4 ‥ 7) ∧ (all ∆(i ≠ j) ∧ (i ≠ j ⇒ ∆(x div i > 2)) | i ∈ 4 ‥ 7)
    = true ∧ (all true ∧ (i ≠ j ⇒ ∆(x div i)) | i ∈ 4 ‥ 7)
    = all i ≠ j ⇒ i ≠ 0 | i ∈ 4 ‥ 7`


```python
def defined(e: Expression) -> Expression:
    """assumes e is well-formed"""
    if isinstance(e, (int, bool, Fraction, str)): return True
    elif isinstance(e, Application):
        if isinstance(e.arg, Sequence):
            args_defined = (defined(a) for a in e.arg) if e.fn != '?' else ()
            denominator_not_zero = (disequality(e.arg[1], 0),) if e.fn in ('/', 'div', 'mod') else ()
            conditional_branches_defined = (defined(e.arg[0]), implication(e.arg[0], defined(e.arg[1])),
            implication(negation(e.arg[0]), defined(e.arg[2]))) if e.fn == '?' else ()
            return conjunction(*args_defined, *denominator_not_zero, *conditional_branches_defined)
        else:
            return defined(e.arg)
    # TODO definedness of function (array) application
    elif isinstance(e, Abstraction):  # ∑, ∏, min, max, all, any, set
        return Application('all', abstraction(e.var, e.range, True,
            conjunction(defined(e.cond), implication(e.cond, defined(e.body)))))
    else:
        assert False, "invalid kind of expression"


e = summation(abstraction('i', Type('‥', 4, 7), disequality('i', 'j'),
    greater(integerdivision('x', 'i'), 2)))
assert str(e) == '∑ (i ∈ 4 ‥ 7, ¬ (i = j) • (x div i) > 2)'
assert str(defined(e)) == 'all (i ∈ 4 ‥ 7 • ¬ (i = j) ⇒ ¬ (i = 0))'
```


```python
SubType = TypeVar('SubType', Expression, Type)
def substitution(e: SubType, sub: Mapping[Text, Expression]) -> SubType:
    if isinstance(e, (int, bool, Fraction)): return e
    elif isinstance(e, str): return sub[e] if e in sub else e
    elif isinstance(e, Application): return Application(e.fn, substitution(e.arg, sub))
    elif isinstance(e, Abstraction):
        s = {x: sub[x] for x in sub if x != e.var}
        # TODO ask check that abstractions should not capture variables in type expressions
        # at the very least it shouldn't capture the abstracted variable until the cond/body
        return Abstraction(e.var, substitution(e.range, sub), substitution(e.cond, s), substitution(e.body, s))
    elif isinstance(e, Type):
        return Type(e.kind, *(substitution(arg, sub) for arg in e.args))
    else: assert False, "invalid kind of expression"


e = maximum(abstraction('x', Type('‥', 4, 'z'), True, addition('x', 'y', 'z')))
assert str(e) == 'max (x ∈ 4 ‥ z • x + y + z)'
assert str(substitution(e, {'x': 3, 'z': 9})) == 'max (x ∈ 4 ‥ 9 • x + y + 9)'
```

## Statement Correctness

The rules for correctness assume that parallel composition has been eliminated:

    ｛a｝ skip ｛c｝                      ≡  a ⇒ c
    ｛a｝ x̅ ≔ e̅ ｛c｝                     ≡  a ⇒ (∆e̅ ∧ c[x̅\e̅])
    ｛a｝ b₁ → s₁ ⫿ b₂ → s₂ ⫿ … ｛c｝      ≡  ｛a ∧ b₁｝ s₁ ｛c｝ ∧ ｛a ∧ b₂｝ s₂ ｛c｝ ∧ …
    ｛a｝ b₁ → s₁ ⫿ b₂ → s₂ ⫿ … ⫽ s₀ ｛c｝  ≡  ｛a ∧ b₁｝ s₁ ｛c｝ ∧ ｛a ∧ b₂｝ s₂ ｛c｝ ∧ … ∧
                                            ｛a ∧ ¬b₁ ∧ ¬b₂ ∧ … ｝ s₀ ｛c｝
    ｛a｝ p₁ : s₁ ⊕ p₂ → s₂ ⊕ … ｛c｝     ≡  （p₁ ≠ 0 ⇒｛a｝s₁｛c｝）∧（p₂ ≠ 0 ⇒ ｛a｝s₂｛c｝）∧ …

    {a} skip {c}                      ≡  a ⇒ c
    {a} x̅ ≔ e̅ {c}                     ≡  a ⇒ (∆e̅ ∧ c[x̅\e̅])
    {a} b₁ → s₁ ⫿ b₂ → s₂ ⫿ … {c}      ≡  {a ∧ b₁} s₁ {c} ∧ {a ∧ b₂} s₂ {c} ∧ …
    {a} b₁ → s₁ ⫿ b₂ → s₂ ⫿ … ⫽ s₀ {c}  ≡  {a ∧ b₁} s₁ {c} ∧ {a ∧ b₂} s₂ {c} ∧ … ∧
                                            ｛a ∧ ¬b₁ ∧ ¬b₂ ∧ … } s₀ ｛c｝
    {a} p₁ : s₁ ⊕ p₂ → s₂ ⊕ … {c}     ≡  (p₁ ≠ 0 ⇒ {a} s₁ {c}) ∧ (p₂ ≠ 0 ⇒ {a} s₂ {c}) ∧ …


```python
Predicate = Expression
def correct(a: Predicate, s: Statement, c: Predicate) -> Predicate:
    if s == skip:
        return implication(a, c)
    elif isinstance(s, Assignment):
        r = implication(a, conjunction(defined(s.expr), substitution(c, {s.var: s.expr})))
    elif isinstance(s, GuardedComp):
        elems_correct = (correct(conjunction(a, guard), body, c) for guard, body in s.elems)
        else_correct = correct(conjunction(a, *(negation(guard) for guard, _ in s.elems)), s.els, c) if s.els is not None else True
        r = conjunction(*elems_correct, else_correct)
    elif isinstance(s, ProbComp):
        r = conjunction(*(implication(disequality(prob, 0), correct(a, body, c)) for prob, body in s.elems))
    else:
        assert False, "invalid kind of statement"
    return simplification(r)
```

**Test 1.**

    {x > 0} x ≔ x - 1 {x ≥ 0}  ≡  (x > 0) ⇒ (x - 1 ≥ 0)


```python
a, s, c = greater('x', 0), Assignment('x', subtraction('x', 1)), greaterequal('x', 0)
assert (str(a), str(s), str(c)) == ('(x > 0)', 'x ≔ (x - 1)', '(x ≥ 0)')
assert str(correct(a, s, c)) == '((x > 0) ⇒ ((x - 1) ≥ 0))'
```

**Test 2.**

    {true} x ≥ 0 → y := x ⫿ x ≤ 0 → y := - x {(y = x ∨ y = -x) ∧ y ≥ 0}  ≡


```python
a = True
s = GuardedComp([
    GuardedCompElem(greaterequal('x', 0), Assignment('y', 'x')),
    GuardedCompElem(lessequal('x', 0), Assignment('y', negative('x')))
])
c = conjunction(disjunction(equality('y', 'x'), equality('y', negative('x'))), greaterequal('y', 0))
assert str(s) == '((x ≥ 0) → y ≔ x ⫿ (x ≤ 0) → y ≔ - x)'
assert str(c) == '(((y = x) ∨ (y = - x)) ∧ (y ≥ 0))'
assert str(correct(a, s, c)) == '((x ≤ 0) ⇒ (- x ≥ 0))'
```

## Chart Correctness

A chart is correct if for any visible (external) event `E`,
- the operation `op(E)` preserves the chart invariant,
- for all transitions taken on that operation, the evaluation of guards and actions must be defined, and
- for all transitions taken on that operation, the conditions of a choice must be complete and disjoint

The _source invariant_ `sourceinv(t)` of transition `t` is the accumulated invariant of the single state. The _target invariant_ `targetinv(t)` is the conjunction of the invariants of all possible target states. These are collected by following all probabilistic alternatives of a transition and all conditional choices of all probabilistic alternatives. If a target state obtained that way is a Basic state, that is included in the set of target states. If it is an Xor state, the initialization of that is recursively followed. If it is an And state, the targets of all initialization of the Xor children is followed:

trigger(t) ≙ test(source(t)) ∧ guard(t)
effect(t)  ≙ ⊕ a ∈ alt(t) . prob(a) : (body(t) ‖ body(a) ‖ comp(cond(a))) [F \ op(F)]
comp(cs)   ≙ ▯ c ∈ cs . guard(c) → body(c) ‖ goto(target(c)) ‖
                                   case target(c) of
                                     Basic: skip
                                     Xor: comp(init(target(c)))
                                     And: ‖ q ∈ children[{target(c)}] . comp(init(q))

    sourceinv(t) ≙ accinv(source(t))
    targetinv(t) ≙ (∧ a ∈ alt(t) . (∧ r ∈ comptargets(cond(a)) . accinv(r)))

    comptargets(cs) ≙ ∪ c ∈ cs . case target(c) of
                                   Basic: {target(c)}
                                   Xor: comptargets(init(target(c))
                                   And: ∪ q ∈ children[{target(c)}] . comptargets(init(q))


```python
help(set().union)
```


```python
def trigger(t: 'transition') -> 'expression':
    return conjunction([test(t.source), t.guard])

def effect(chart: 'pChart', t: 'transition') -> 'statement':
    return prob([(p, parallel([t.body, y, comp(chart, t.source, cs)])) for (p, y, cs) in t.alt])

def comp(chart: 'pChart', s: 'state', cs: 'condition set') -> 'statement':
    return guarded([(g, parallel([y, skip if s == r or s.parent == r else goto(r),
                                  skip if r in chart.Basic else
                                  comp(chart, r, r.init) if r in chart.Xor else
                                  parallel([comp(chart, q, q.init) for q in r.children])
                                 ])) for (g, y, r) in cs])

def sourceInvariant(chart, t: 'transition') -> 'expression':
    return accumulatedInvariant(chart, t.source)

def targetInvariant(chart, t: 'transition') -> 'expression':
    return conjunction([accumulatedInvariant(r) for (p, y, cs) in t.alt for r in comptargets(chart, cs)])
#     comptargets(cs) ≙ ∪ c ∈ cs . case target(c) of
#                                    Basic: {target(c)}
#                                    Xor: comptargets(init(target(c))
#                                    And: ∪ q ∈ children[{target(c)}] . comptargets(init(q))
def comptargets(chart, cs: 'condition set') -> 'state set':
    # return {r if r in chart.Basic else comptargets(chart, r.init) if r chart.Xor else \
    #         {comptargets(chart, q.init) for q in r.children} for (g, y, r) in cs}
    return {r for (g, y, r) in cs if r in chart.Basic} | \
           comptargets()
```

    correct(e) ≙ scopeop(e, root)
    scopecorrect(e, s) ≙ (∧ t ∈ trans(e, s) .{sourceinv(t) ∧ trigger(t)} effect(t) {targetinv(t)} ∧
                         (( t ∈ trans(e, s) . ¬trigger(t)) ⇒ childcorrect(E, s))
    childcorrect(e, s) ≙ case s of
                           Basic: true
                           Xor: ∧ c ∈ children[{s}] . scopecorr(E, c)
                           And: {accinv(s)} childop(E, s) {accinv(s)}

