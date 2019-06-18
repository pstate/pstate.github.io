

```python
from dataclasses import dataclass
from fractions import Fraction
from typing import Mapping, Any, Optional, MutableSet, Text, Set, MutableMapping, NamedTuple

from pstate.core.core import State, Transition, ChartException, Expression, Event, Type, Statement, Error, ChartMessage, \
    equality, skip, Assignment, conjunction, prob, parallel, Conditional, guarded, Alternative, ProbComp, ProbCompElem, \
    ParallelComp, GuardedCompElem, GuardedComp, Application, Skip, implication, parent_transitive_closure
from pstate.core.serialization import inflate
```

## Generating the Intermediate Representation

### PCharts

A _pChart_ is a tuple consisting of a root state, pairwise disjoints sets of Basic, And, Xor states, and a set of transitions.

**Representation.** PCharts are represented by `Chart` objects with corresponding fields. Additionally, `Chart` objects have field `intermediate` for the generated intermediate code.


```python
@dataclass()
class Chart:
    root: Optional[State] = None
    Basic: Optional[MutableSet[State]] = None
    Xor: Optional[MutableSet[State]] = None
    And: Optional[MutableSet[State]] = None
    transitions: Optional[MutableSet[Transition]] = None
    inter: Optional['Intermediate'] = None

    def _clear(self):
        self.root = self.Basic = self.Xor = self.And = self.transitions = self.inter = None

    def convert(self, stategraph: MutableMapping[Text, Any]) -> Optional[ChartException]:
        try:
            self.root, self.Basic, self.Xor, self.And, self.transitions = inflate(stategraph)
            generateUniqueNames(self)
            self.inter = genIntermediateCode(self)
            return None
        except ChartException as e:  # e.args is tuple with potentially a single element
            self._clear()
            return e

    def code(self) -> 'Intermediate':
        return self.inter

    def invariant(self, state: Optional[State] = None) -> Expression:
        return accumulatedInvariant(self, state if state else self.root)

    def costs(self, state: Optional[State] = None) -> "partial cost for composite, total for basic states":
        return partialCost(state if state else self.root)

    def events(self, state: Optional[State] = None) -> Set[Event]:
        return visibleEvents(self, state if state else self.root)
```

The remainder of this notebook develops the procedures called above.

- The state `root` cannot be the source or part of the target or a transition.
- The `parent` function induces a tree that is rooted in `root`, i.e. from any state `root` is reached after a finite number of applications of `parent`.
- All assignment statements have to be type-correct, i.e. the types of the left and right hand side have to agree
- All broadcast statements have to be conflict-free, in a sense to be defined shortly.
- Same costs must have convertible units.

### Intermediate Representation and Transition Systems

A program in the _intermediate representation_ consists of a collection of variable and procedure declarations together with an initialization:

| Declaration    | Notation           | |
|:---------------|:-------------------|:-------------|
| Variable       | `var v: V`         | declare variable `v` of type `V` |
| Initialziation | `init s`           | initialize program with statement `s` |
| Procedure      | `procedure m ≙ s`  | name statement `s` as `m` |

**Representation.** Programs in the intermediate representation are represented by object of their respective class.


```python
class Intermediate(NamedTuple):
    var: Mapping[Text, Type]
    init: Statement
    proc: Mapping[Text, Statement]

    def __str__(self):
        return '\n'.join(['var ' + v + ': ' + str(self.var[v]) for v in self.var] + ['init ' + str(self.init)] + [
            ('procedure ' + m + ' ≙\n' + str(self.proc[m])).replace('\n', '\n    ') for m in self.proc])
```


```python
assert str(Intermediate({'x': Type('integer'), 'y': Type('bool')}, 'I', {'m': 's', 'n': 't'})) == \
    'var x: integer\nvar y: bool\ninit I\nprocedure m ≙\n    s\nprocedure n ≙\n    t'
```


```python
def transitions(proc: 'program') -> '':
    return {m: normalize(s, proc) for m, s in proc}

def normalize():
    pass
```

### Generating Unique Names

In a state hierarchy, different states and variables may have the same name. To aid further processing of charts in flat, textual form (code generators, provers), state and variable names that are unique to the chart need to be determined. The rules for state and variable names in charts are:

- State, variable, constant, and event names may contain uppercase letters lowercase letter, numbers, and other symbols like subscripted numbers, but must not start with a number and must not contain an underscore (`_`).
- A child state may have the same name as its parent or any ancestor, but the names of all siblings must differ more than just by capitalization. For example, `X1` and `x1` cannot be children of the same parent, but `X1` and `X2` can. Children of distinct parents can have the same name.
- Variables and constants declared in a state must have names unique among all variables and constants of that state. Variables declared in different states may have the same name, also if one state is the descendant of another.
- The variable names declared in a state must differ from the names of all children of that state by more than just capitalization. For example, `X1` and `x1` cannot be the name of a variable and a child of state, but `X1` and `X2` can.

As local variables are represented by a dictionary mapping the variable name to its declaration, the construction of a chart state already ensured that variable names are unique local to that state. Procedure `generateUniqueNames(c)` traverses all states of chart `c` and determines state and variable names that are unique to the chart: field `unique_name` of a state becomes the unique name of the state and field `unique_vars` of a state becomes a dictionary mapping a unique variable name to its declared name in that state. Unique names may differ only in the capitalization.

The traversal of states in `generateUniqueNames(c)` starts with the root of chart `c`, then all children of the root, then all grandchildren of the root, etc. If in one generation two or more states that are not siblings have the same name, the unique name of the respective parent is prepended to each of those states; the invariant is that the states of all visited generations have already unique names. As state names cannot contain an underscore, that character is used to separate the prefix, thus ensuring that the newly constructed name is unique indeed. This may result in unique names that have multiple prefixes. The algorithm ensures that if two unique names have common prefixes, the one with more prefixes is from a younger generation, i.e. a deeper nested state.

States that do not have names are assigned one: the unique name of the parent is taken and a number is appended, separated by `_`. As state names cannot be numbers, the newly constructed name is distinct from all named states. In `generateVariables(s)`, the number assigned is unique to each generation. If the root state does not have a name, `'root'` is used.

Unique variable names are generated similarly as with states: traversing generation by generation, if a duplicate is found, the unique name of the state in which the variable is declared is prepended. State names may also be constructed by appending the parent name, but since the name of a variable has to differ by more than just capitalization from the children of a state, the newly constructed varialbe name cannot clash with a state name. The unique variable name is stored in the field `unique_vars` that maps it to the declared name.

Procedure `generateVariables(s)` first disambiguates state names and then disambiguates variable names, for each generation. Variable `names` is a set of all names visited so far, normalized to lower case. A name is added to the set `dups` if it is encountered more than once and needs disambiguation.


```python
def generateUniqueNames(c: Chart):
    r = c.root
    r.unique_name = r.name.lower() if r.name else 'root'
    r.unique_vars = {r.unique_name + '_' + v if v.lower() == r.unique_name else v: v for v in r.var}
    visit, dups, names = {r}, set(), {r.unique_name} | r.unique_vars.keys()
    # invariant: for all states v in chart c that were visited so far, v.unique_name differ in more
    # than capitalization and the keys of v.unique_vars are all distinct and all differ from
    # s.unique_name.lower() and s.unique_name.capitalize for all states s
    while len(visit) > 0:
        for s in visit:  # check s for unique child names
            childnames = {c.name for c in s.children if c.name}
            normalizedchildnames = {c.name.lower() for c in s.children if c.name}
            if len(normalizedchildnames) < len(childnames):
                raise Error('Children have same or similar names', s)
            elif any(v.lower() in normalizedchildnames for v in s.unique_vars):
                raise Error('Child has same or similar name as variable', s)
        visit, noname = {c for s in visit for c in s.children}, 1
        for s in visit:  # check for state names that need disambiguation
            if s.name:
                if s.name.lower() in names or s.name.capitalize() in names: dups.add(s.name)
                names.add(s.name.lower()); names.add(s.name.capitalize())
        for s in visit:  # disambiguate state names
            if s.name:
                s.unique_name = s.parent.unique_name + '_' + s.name if s.name in dups else s.name.capitalize()
            else: s.unique_name = s.parent.unique_name + '_' + str(noname); noname += 1
        for s in visit:  # check for duplicate variable names
            for v in s.var:
                if v in names: dups.add(v)
                else: names.add(v)
        for s in visit:  # disambiguate variable names
            s.unique_vars = {s.unique_name + '_' + v if v in dups else v: v for v in s.var}

# TODO link test_intermediate_unique.py
```

For the configuration variables we have:


```python
def configurationVariables(chart, s) -> MutableMapping[Text, MutableSet[Text]]:
    """
    :returns map of implicitly declared state configuration variables (str)
    to set of child state configuration vars (also str)
    """
    var = {s.unique_name.lower(): {c.unique_name for c in s.children}} if len(s.children) > 1 else {}
    for c in s.children & chart.Xor: var.update(configurationVariables(chart, c))
    return var

# TODO link test_intermediate_unique.py#test_configuration_vars
```

For the generated declared variables we have:


```python
def declaredVariables(chart, s: State) -> MutableMapping[Text, Type]:
    """
    :returns maps unique var name to Type
    """
    var = {uv: s.var[v] for uv, v in s.unique_vars.items()}
    # TODO ASK why are basic not included?
    # for c in s.children - chart.Basic: var.update(declaredVariables(chart, c))
    for c in s.children: var.update(declaredVariables(chart, c))
    return var

# TODO link test_intermediate_unique.py#test_declared_vars
```

### Generating Intermediate Code

For representing the configuration (or "state") of a chart, a flat collection of variables is used: this makes it simple to express independent updates of concurrent states and state tests of any state in the hierarchy in the translation to a programming language, including assembly. For every Xor state `s`, including `root`, a variable `lc(s)`, ranging over `uc(c)` for every child `c` of `s`, is declared. Intuitively, `lc(s)` and `uc(s)` are the name of state `s` starting with a lowercase or an uppercase letter. More precisely, `lc(s)` and `uc(s)` must be distinct from each other and distinct from both `lc(t)` and `uc(t)`, for any state `t ≠ s`.

**Repesentation.** The unique state name is used for `lc(s)` and `uc(s)`; procedure `generateUniqueNames(c)` ensures that unique state names are capitalized, hence we can use:

    lc(s) ≙ s.unique_name.lower()
    uc(s) ≙ s.unique_name

The manipulation of configurations is expressed in terms of `test(s)` and `goto(s)`, provided that `parent(s)` is an Xor state:

    test(s) ≙ lc(parent(s)) = uc(s)
    goto(s) ≙ lc(parent(s)) := uc(s)

If an Xor state has only a single child, testing for being in that child is always true and moving the configuration to that child cannot change the configuration, so is `skip`. The implementation makes these optimizations:


```python
def test(s: 'Xor child'):
    return True if len(s.parent.children) == 1 else \
        equality(s.parent.unique_name.lower(), s.unique_name)

def goto(s: 'Xor child'):
    return skip if len(s.parent.children) == 1 else \
        Assignment(s.parent.unique_name.lower(), s.unique_name)
```

A single transition is translated to a guarded statement. The guard of the statement, the _trigger_, is true if the configuration is in the source state of the transition and the transition guard is true. The body of the statement, _the effect_, moves the chart to the next configuration. The effect of transition `t` is a probabilistic choice among its alternatives, `alt(t)`; by the well-formedness of transitions, the probabilities must be non-negative and must sum up to `1`. Each probabilistic alternative `a ∈ alt(t)` is the parallel composition of the body of that alternative, `body(a)`, and the _completion_ of the conditional, `comp(cond(a))`. That in turn is the nondeterministic choice among the conditionals, where the guards of the conditionals have to be _disjoint_ and _complete_, i.e. their disjunction has to be `true`. In case the target of a conditional is Xor state, the completion adds the initialization of that state. In case the target is an And state, the completion adds the initialization of all children of that state, which are required to be Xor states.

TODO A transition may also broadcast an event, say `F`, either explicitly or implicitly in one of the alternatives of its completion; any transition taken on `F` is taken jointly with those on E and if no transition on `F` can be taken, broadcasting `F` behaves as `skip`. Thus the meaning of broadcasting `F` is that of `op(F)`. We write `S[F\T]` for replacing event `F` by `T` in statement `S`:

    trigger(t) ≙ test(source(t)) ∧ guard(t)
    effect(t)  ≙ ⊕ a ∈ alt(t) . prob(a) : (body(t) ‖ body(a) ‖ comp(cond(a))) [F \ op(F)]
    comp(cs)   ≙ ▯ c ∈ cs . guard(c) → body(c) ‖ goto(target(c)) ‖
                                       case target(c) of
                                         Basic: skip
                                         Xor: comp(init(target(c)))
                                         And: ‖ q ∈ children[{target(c)}] . comp(init(q))


```python
# assumes that the chart is well-formed, in particular that
# - probabilities sum up to 1
# - guards are disjoint and complete
# - children of And are Xor
# - source and targets have the same parent or are each other's parent
# - scope is Xor
# - init goes to child

# TODO explain two optimizations in comp

def trigger(t: Transition) -> Expression:
    return conjunction(test(t.source), t.guard)


def effect(chart: Chart, t: Transition) -> Statement:
    return prob(*((a.prob, parallel(t.body, a.body, comp(chart, t.source, a.cond))) for a in t.alt))

# TODO ask, where/what is s from/for? Also there seems to be some bit rot in
def comp(chart: Chart, s: State, cs: Set[Conditional]) -> Statement:
    return guarded(*((c.guard, parallel(
        c.body,
        skip if s == c.target or s.parent == c.target else goto(c.target),
        skip if c.target in chart.Basic else
        comp(chart, c.target, c.target.init) if c.target in chart.Xor else
        parallel(*(comp(chart, q, q.init) for q in c.target.children))
    )) for c in cs))
```

**Test 1.**

    A ---E[g]/S-@p/T-[h]/U-> B
                    -[i]/V-> C
               -@q/W-------> D


```python
r = State('root', None); A = State('A', r)
B = State('B', r); C = State('C', r)
D = State('D', r); c = Chart()
c.root, c.Basic, c.And, c.Xor = r, {A, B, C, D}, set(), {r}
r.children = {A, B, C, D}
generateUniqueNames(c)
t = Transition("t", A, 'E', 'g', {}, 'S', [
    Alternative(Fraction(1, 4), 'T', {Conditional('h', 'U', B), Conditional('i', 'V', C)}),
    Alternative(Fraction(3, 4), 'W', {Conditional(True, skip, D)})
])

assert str(trigger(t)) == '((root = A) ∧ g)'
'(1/4 : (S ∥ T ∥ (i → (V ∥ root ≔ C) ⫿ h → (U ∥ root ≔ B))) ⊕ 3/4 : (S ∥ W ∥ root ≔ D))'
assert effect(c, t) == ProbComp(elems=[ProbCompElem(prob=Fraction(1, 4), body=ParallelComp(elems=['S', 'T', GuardedComp(
    elems=[GuardedCompElem(guard='i', body=ParallelComp(elems=['V', Assignment(var='root', expr='C')])),
           GuardedCompElem(guard='h', body=ParallelComp(elems=['U', Assignment(var='root', expr='B')]))], els=None)])),
                                       ProbCompElem(prob=Fraction(3, 4), body=ParallelComp(
                                           elems=['S', 'W', Assignment(var='root', expr='D')]))])
```

**Test 2.**

    A ---E/S--> B-----------------------+
                |-/T-> C-----------+  F |
                |      | -/U-> D  E|    |
                |      +-----------+    |
                +-----------------------+


```python
r = State('root', None); A = State('A', r)
B = State('B', r); C = State('C', B)
D = State('D', C); E = State('E', C)
F = State('F', B)
c = Chart()
c.root, c.Basic, c.And, c.Xor = r, {A, D, E, F}, set(), {r, B, C}
r.children |= {A, B}
B.children |= {C, F}
C.children |= {D, E}
B.init |= {Conditional(True, 'T', C)}; C.init |= {Conditional(True, 'U', D)}
generateUniqueNames(c)
t = Transition("t", A, 'E', True, {}, 'S', [Alternative(Fraction(1), skip, {Conditional(True, skip, B)})])

assert str(trigger(t)) == '(root = A)'
assert str(effect(c, t)) == '(S ∥ root ≔ B ∥ T ∥ b ≔ C ∥ U ∥ c ≔ D)'
```

**Test 3.**

    A ---E[g]/S--> B------------+
                   | C          |
                   | -> D E     |
                   |============|
                   | F          |
                   | -[h]/T-> G |
                   | -[i]/U-> H |
                   +------------+

Here, the children of `B` are represented as a list, not a set, to have a deterministic outcome of `effect` for the purpose of testing.


```python
r = State('root', None); A = State('A', r)
B = State('B', r); C = State('C', B)
D = State('D', C); E = State('E', C)
F = State('F', B); G = State('G', F)
H = State('H', F); c = Chart()
c.root, c.Basic, c.And, c.Xor = r, {A, D, E, G, H}, {B}, {r, C, F}
r.children |= {A, B}
B.children |= {C, F}
C.children |= {D, E}
F.children |= {G, H}
C.init |= {Conditional(True, skip, D)}; F.init |= {Conditional('h', 'T', G), Conditional('i', 'U', H)}
generateUniqueNames(c)
t = Transition("t", A, 'E', 'g', {}, 'S', [Alternative(Fraction(1), skip, {Conditional(True, skip, B)})])

assert str(trigger(t)) == '((root = A) ∧ g)'
'(S ∥ root ≔ B ∥ c ≔ D ∥ (h → (T ∥ f ≔ G) ⫿ i → (U ∥ f ≔ H)))'
assert effect(c, t) == ParallelComp(elems=['S', Assignment(var='root', expr='B'), GuardedComp(
    elems=[GuardedCompElem(guard='h', body=ParallelComp(elems=['T', Assignment(var='f', expr='G')])),
        GuardedCompElem(guard='i', body=ParallelComp(elems=['U', Assignment(var='f', expr='H')]))], els=None),
    Assignment(var='c', expr='D')])
```

**Test 4.**

    A--------+
    | B -E-+ |
    | ^    | |
    | +----+ |
    +--------+


```python
r = State('root', None); A = State('A', r)
B = State('B', A); c = Chart()
c.root, c.Basic, c.And, c.Xor = r, {B}, set(), {r, A}
r.children |= {A}
A.children |= {B}
generateUniqueNames(c)
t = Transition("t", B, 'E', True, {}, skip, [Alternative(Fraction(1), skip, {Conditional(True, skip, B)})])

assert str(trigger(t)) == 'True'
assert str(effect(c, t)) == 'skip'
```

**Test 5.**

    A----------+  D
    +-E-> B  C |
    +----------+


```python
r = State('root', None); A = State('A', r)
B = State('B', A); C = State('C', A)
D = State('D', r); c = Chart()
c.root, c.Basic, c.And, c.Xor = r, {B, C, D}, set(), {r, A}
r.children |= {A, D}
A.children |= {B, C}
generateUniqueNames(c)
t = Transition("t", A, 'E', True, {}, skip, [Alternative(Fraction(1), skip, {Conditional(True, skip, B)})])

assert str(trigger(t)) == '(root = A)'
assert str(effect(c, t)) == 'a ≔ B'
```

The _scope_ of a transition is the state that "contains" both the source and all targets of a transition. Two cases are distinguished:
- If all targets are either the source itsself, a sibling of the source, or the parent of the source, the scope is the parent of the source.
- If all targets are childen of the source, the scope is the source itself.

A transition must conform to either restriction. Visually, this ensures that a transition can be drawn without crossing state contours. Here,`o` stands for a P or C pseudo-state

    +------------+    +---------+
    |A     ^     |    |A        |
    |      |     |    +-E-o-> B |
    | B -E-o-> C |    |   |     |
    | ^    |     |    |   v     |
    | +----+     |    |   C     |
    +------------+    +---------+

The scope is the state in which the transition resides, `A` in both examples above. For brevity, let `trans(E, s)` stand for the set of transitions on event `E` with scope `s`:

    scope(t) ≙ that s .
                 (∀ a ∈ alt(t), c ∈ cond(a) .
                   (parent(target(c)) = parent(source(t)) ∨ target(c) = parent(source(c))) ∧
                    s = parent(source(t))) ∨
                 (∀ a ∈ alt(t), c ∈ cond(a) .
                    parent(target(c)) = source(t) ∧ s = source(t))

    trans(E,s) ≙ {t | event(t) = E ∧ scope(t) = s}

The implementation assumes that the transition conforms to one of above restrictions and tests by `any((r.parent == t.source for (p, x, cs) in t.alt for (g, y, r) in cs))` if is is the second one.


```python
def trans(chart, e, s):
    return {t for t in chart.transitions if t.event == e and s == (t.source if
        any((r.parent == t.source for (p, x, cs) in t.alt for (g, y, r) in cs)) else
        t.source.parent)}
```

The _operation_ `op(E)` of an event `E` is a statement that captures the joint meaning of all transitions of a chart on `E`. It recursively visits all transitions on `E`, starting with those on the outermost scope, `root`. In case there are two or more transitions with the same scope, a nondeterministic choice among those is returned. In case there are transitions on different scopes, transitions on outer scopes are given priority. In case there transitions on the same event in concurrent states, these are taken in parallel. If in a configuration no transition is specifed on an event or there is a transition but it is not enable, the effect is to do nothing, i.e. skip, rather than to block.

    op(e)         ≙ scopeop(e, root)
    scopeop(E, s) ≙ (▯ t ∈ trans(E, s) . trigger(t) → effect(t)) ⫽
                    childop(E,s)
    childop(E, s) ≙ case s of
                      Xor: ▯ c ∈ children[{s}] − Basic . test(c) → scopeop(E,c) ⫽ skip
                      And: ‖ c ∈ children[{s}] − Basic . scopeop(E,c)
                    end


```python
def op(chart, e):
    return scopeop(chart, e, chart.root)

def scopeop(chart, e, s):
    tr = [(trigger(t), effect(chart, t)) for t in trans(chart, e, s)]
    return guarded(*tr, els=childop(chart, e, s))

def childop(chart, e, s):
    if s in chart.Xor:
        tt = [(test(c), scopeop(chart, e, c)) for c in s.children - chart.Basic]
        return guarded(*tt, els=skip)
    else:  # s in And
        return parallel(*(scopeop(chart, e, c) for c in s.children - chart.Basic))
```

**Test 1.**

    S -- E[g]/x -P- @1/4/y --> T
                    @3/4/z -C- [h1]/z1-> U
                               [h2]/z2-> U



```python
r = State('', None); S = State('S', r); T = State('T', r)
U = State('U', r); r.children = {S, T, U}
t = Transition('t', S, 'E', 'g', {}, 'x', [Alternative(Fraction(1, 4), 'y', {Conditional(True, skip, T)}),
    Alternative(Fraction(3, 4), 'z', {Conditional('h1', 'z1', U), Conditional('h2', 'z2', U)})])
c = Chart()
c.Basic, c.And, c.Xor, c.root, c.transitions = {S, T, U}, set(), {r}, r, {t}
generateUniqueNames(c)
trans(c, 'E', r)

'(((root = S) ∧ g) → (1/4 : (x ∥ y ∥ root ≔ T) ⊕ 3/4 : (x ∥ z ∥ (h1 → (z1 ∥ root ≔ U) ⫿ h2 → (z2 ∥ root ≔ U)))) ⫽ skip)'
assert op(c, 'E') == GuardedComp(elems=[
    GuardedCompElem(guard=Application(fn='∧', arg=[Application(fn='=', arg=['root', 'S']), 'g']), body=ProbComp(
        elems=[ProbCompElem(prob=Fraction(1, 4), body=ParallelComp(elems=['x', 'y', Assignment(var='root', expr='T')])),
            ProbCompElem(prob=Fraction(3, 4), body=ParallelComp(elems=['x', 'z', GuardedComp(
                elems=[GuardedCompElem(guard='h1', body=ParallelComp(elems=['z1', Assignment(var='root', expr='U')])),
                    GuardedCompElem(guard='h2', body=ParallelComp(elems=['z2', Assignment(var='root', expr='U')]))],
                els=None)]))]))], els=Skip())
```

**Test 2.**

    A --E[g]/x--> B --E[h]/y-- C


```python
r = State('root', None); A = State('A', r); B = State('B', r)
C = State('C', r); r.children = {A, B, C}
t = Transition('t', A, 'E', 'g', {}, 'x', [Alternative(Fraction(1), skip, {Conditional(True, skip, B)})])
u = Transition('u', B, 'E', 'h', {}, 'y', [Alternative(Fraction(1), skip, {Conditional(True, skip, C)})])
c = Chart()
c.Basic, c.And, c.Xor, c.root, c.transitions = {A, B, C}, set(), {r}, r, {t, u}
generateUniqueNames(c)

assert op(c, 'E') == GuardedComp(elems=[
    GuardedCompElem(guard=Application(fn='∧', arg=[Application(fn='=', arg=['root', 'B']), 'h']),
        body=ParallelComp(elems=['y', Assignment(var='root', expr='C')])),
    GuardedCompElem(guard=Application(fn='∧', arg=[Application(fn='=', arg=['root', 'A']), 'g']),
        body=ParallelComp(elems=['x', Assignment(var='root', expr='B')]))], els=Skip())
```

**Test 3.**

    A-----------------+
    | B - E[g]/x -> C +- E[h]/y -> D
    +-----------------+


```python
r = State('root', None); A = State('A', r); B = State('B', A)
C = State('C', A); D = State('D', r)
r.children, A.children = {A, D}, {B, C}
t = Transition('t', B, 'E', 'g', {}, 'x', [Alternative(Fraction(1), skip, {Conditional(True, skip, C)})])
u = Transition('u', A, 'E', 'h', {}, 'y', [Alternative(Fraction(1), skip, {Conditional(True, skip, D)})])
c = Chart()
c.Basic, c.And, c.Xor, c.root, c.transitions = {B, C, D}, set(), {r, A}, r, {t, u}
generateUniqueNames(c)

'(((root = A) ∧ h) → (y ∥ root ≔ D) ⫽ ((root = A) → (((a = B) ∧ g) → (x ∥ a ≔ C) ⫽ skip) ⫽ skip))'
assert op(c, 'E') == GuardedComp(elems=[
    GuardedCompElem(guard=Application(fn='∧', arg=[Application(fn='=', arg=['root', 'A']), 'h']),
                    body=ParallelComp(elems=['y', Assignment(var='root', expr='D')]))],
    els=GuardedComp(elems=[GuardedCompElem(guard=Application(fn='=', arg=['root', 'A']), body=GuardedComp(elems=[
        GuardedCompElem(guard=Application(fn='∧', arg=[Application(fn='=', arg=['a', 'B']), 'g']),
                        body=ParallelComp(elems=['x', Assignment(var='a', expr='C')]))], els=Skip()))], els=Skip()))
```

**Test 4.**

    A---------------------+
    | B                   |
    |   B1 - E[g]/x -> B2 |
    +=====================+- E[i]/z -> D
    | C                   |
    |   C1 - E[h]/y -> C2 |
    +---------------------+


```python
r = State('root', None); A = State('A', r); B = State('B', A)
B1 = State('B1', B); B2 = State('B2', B); C = State('C', A)
C1 = State('C1', C); C2 = State('C2', C); D = State('D', r)
r.children, A.children, B.children, C.children = {A, D}, {B, C}, {B1, B2}, {C1, C2}
t = Transition('t', B1, 'E', 'g', {}, 'x', [Alternative(Fraction(1), skip, {Conditional(True, skip, B2)})])
u = Transition('u', C1, 'E', 'h', {}, 'y', [Alternative(Fraction(1), skip, {Conditional(True, skip, C2)})])
v = Transition('v', A, 'E', 'i', {}, 'z', [Alternative(Fraction(1), skip, {Conditional(True, skip, D)})])
c = Chart()
c.Basic, c.And, c.Xor, c.root, c.transitions = {B1, B2, C1, C2, D}, {A}, {r, B, C}, r, {t, u, v}
generateUniqueNames(c)

'(((root = A) ∧ i) → (z ∥ root ≔ D) ⫽ ((root = A) → ((((c = C1) ∧ h) → (y ∥ c ≔ C2)) ∥ (((b = B1) ∧ g) → (x ∥ b ≔ B2)))))'
assert op(c, 'E') == GuardedComp(elems=[
    GuardedCompElem(guard=Application(fn='∧', arg=[Application(fn='=', arg=['root', 'A']), 'i']),
                    body=ParallelComp(elems=['z', Assignment(var='root', expr='D')]))],
    els=GuardedComp(elems=[
        GuardedCompElem(guard=Application(fn='=', arg=['root', 'A']), body=ParallelComp(elems=[GuardedComp(elems=[
            GuardedCompElem(guard=Application(fn='∧', arg=[Application(fn='=', arg=['c', 'C1']), 'h']),
                            body=ParallelComp(elems=['y', Assignment(var='c', expr='C2')]))], els=Skip()),
            GuardedComp(elems=[
                GuardedCompElem(guard=Application(fn='∧', arg=[Application(fn='=', arg=['b', 'B1']), 'g']),
                                body=ParallelComp(elems=['x', Assignment(var='b', expr='B2')]))], els=Skip())]))],
        els=Skip()))
```

**Test 5.** TODO Are these priorities inutitive?

    A-----------------+
    +-E[g]-> B -E-> C +- E[f]-> D
    +-----------------+


```python
r = State('root', None); A = State('A', r); B = State('B', A)
C = State('C', A); D = State('D', r); c = Chart()
c.root, c.Basic, c.And, c.Xor = r, {B, C, D}, set(), {r, A}
r.children = {A, D}; A.children = {B, C}
B.children = set(); C.children = set()
generateUniqueNames(c)
t = Transition('t', A, 'E', 'g', {}, skip, [Alternative(Fraction(1), skip, {Conditional(True, skip, B)})])
u = Transition('u', B, 'E', True, {}, skip, [Alternative(Fraction(1), skip, {Conditional(True, skip, C)})])
v = Transition('v', A, 'E', 'f', {}, skip, [Alternative(Fraction(1), skip, {Conditional(True, skip, D)})])
c.transitions = {t, u, v}

'(((root = A) ∧ f) → root ≔ D ⫽ ((root = A) → ((a = B) → a ≔ C ⫿ ((root = A) ∧ g) → a ≔ B)))'
assert op(c, 'E') == GuardedComp(elems=[
    GuardedCompElem(guard=Application(fn='∧', arg=[Application(fn='=', arg=['root', 'A']), 'f']),
                    body=Assignment(var='root', expr='D'))],
    els=GuardedComp(elems=[
        GuardedCompElem(guard=Application(fn='=', arg=['root', 'A']), body=GuardedComp(
            elems=[GuardedCompElem(guard=Application(fn='=', arg=['a', 'B']), body=Assignment(var='a', expr='C')),
                   GuardedCompElem(guard=Application(fn='∧', arg=[Application(fn='=', arg=['root', 'A']), 'g']),
                                   body=Assignment(var='a', expr='B'))], els=Skip()))], els=Skip()))
```

**Test 6.**

    o-> A-------------+  D
        +<-E- B  C<-o |
        +-------------+


```python
r = State('root', None); A = State('A', r)
B = State('B', A); C = State('C', A)
D = State('D', r); c = Chart()
c.root, c.Basic, c.And, c.Xor = r, {B, C, D}, set(), {r, A}
r.children, r.var = {A, D}, set(); A.children, A.var = {B, C}, set()
B.children, B.var = set(), set(); C.children, C.var = set(), set()
generateUniqueNames(c)
t = Transition("t", B, 'E', True, {}, skip, [Alternative(Fraction(1), skip, {Conditional(True, skip, A)})])
c.transitions = {t}; r.init |= {Conditional(True, skip, A)}; A.init |= {Conditional(True, skip, C)}

assert str(op(c, 'E')) == '((root = A) → ((a = B) → a ≔ C ⫽ skip) ⫽ skip)'
```

## Accumulating Invariants

Invariants are attached to Basic, Xor, and And states. As the configuration of a chart moves from a set of states to another set of of states, the invariants attached to those states have to hold:

- if the chart is in a Basic state, the attached invariant has to hold;
- if the chart is in an Xor state, it is in exactly one of the children and the invariant of the Xor state and that of the child has to hold;
- if the chart is in an And state, it is also in all of its children and the invariant of the And states and those of its chidren have to hold.

The _chart invariant_ is determined by recursively visiting all states, starting from the root state:

    chartinv    ≙ scopeinv(root)
    scopeinv(s) ≙ inv(s) ∧ childinv(s)
    childinv(s) ≙ case s of
                    Basic: true
                    Xor:   ⋀ c ∈ children[{s}] . test(c) ⇒ scopeinv(c)
                    And:   ⋀ c ∈ children[{s}] . scopeinv(c)
                  end

The scope invariant of state `s` is the invariant of `s` and all its children, the child invariant of `s` is the invariant of its children only. In the implementation, the chart is as an explicit parameter of the corresponding functions:


```python
def scopeInvariant(chart, s):
    return conjunction(s.inv, childInvariant(chart, s))

def childInvariant(chart, s):
    return True if s in chart.Basic else \
        conjunction(*(scopeInvariant(chart, c) for c in s.children)) if s in chart.And else \
        conjunction(*(implication(test(c), scopeInvariant(chart, c)) for c in s.children))


# TODO link test_nondeterminism
```

The _accumulated invariant_ of state `s` is the combination of the state tests and invariants of ancestors and descendants that have to hold when the chart is in `s`: if a chart is in `s`, then

- the scope invariant of `s` holds,
- for all proper ancestors of `s`, the invariant of `s` holds,
- for all ancestors `a` of `s`, including `s`, that are children of Xor states, the test for being in `a` holds,
- for all ancestors `a` of `s`, including `s`, that are children of And states, the scope invariant of all of `a`'s siblings holds.

Formally, this is expressed as:

    accinv(s)  ≙  scopeinv(s) ⋀
                  (⋀ a ∈ parent*[{s}] - {root} .
                      inv(parent(a)) ⋀
                      (parent(a) ∈ Xor ⇒ test(a)) ⋀
                      (parent(a) ∈ And ⇒  ⋀ c ∈ children[{parent(a)}] - {a} . scopeinv(c))

In the implementation, the computation of the transitive closure of `parent` is replaced with an iteration from `s` to the root. As the parent of the root is `None`, the iteration continues as long as the parent of the current state is not `None`:


```python
def accumulatedInvariant(chart, s: State):
    return conjunction(
        scopeInvariant(chart, s),
        conjunction(*(
            conjunction(
                a.parent.inv,
                implication(a.parent in chart.Xor, test(a)),
                implication(a.parent in chart.And, conjunction(*(
                    scopeInvariant(chart, c) for c in a.siblings(reflexive=False))))
            ) for a in parent_transitive_closure(s, reflexive=True, include_root=False)
        )))
    # works for all test cases
    # accinv, p = scopeInvariant(chart, s), s.parent
    # while p:  # p is Xor or And state
    #     inv = test(s) if p in chart.Xor else \
    #           conjunction(*(scopeInvariant(chart, c) for c in p.children if s != c))
    #     p, s, accinv = p.parent, p, conjunction(accinv, inv, p.inv)
    # return accinv


# TODO link test_nondeterminism
```


```python
# pc = pChart('test'); pc
```


```python

```


```python
# pc
```

TODO `top`

Function `visibleEvents(chart, s)` returns the set of all events that have a transition within state `s` or its children but are not local to `s` or its children. Hence, `visibleEvents(chart, chart.root)` are all the global events of `chart`. The function first determines the transitions with scope `s` and recursively those that have a child of `s` as scope and then subtracts those that are declared local to `s`:


```python
def visibleEvents(chart, s) -> "set of events":
    return {t.event for t in chart.transitions if isinstance(t.event, str)} - s.ev
    # | set().union(visibleEvents(chart, c) for c in s.children))
```


```python
def genIntermediateCode(chart) -> Intermediate:
    var = configurationVariables(chart, chart.root)
    var.update(declaredVariables(chart, chart.root))
    init = comp(chart, chart.root, chart.root.init)
    proc = {e: op(chart, e) for e in visibleEvents(chart, chart.root)}
    return Intermediate(var, init, proc)
```
