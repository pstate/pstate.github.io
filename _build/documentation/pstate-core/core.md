---
interact_link: content/documentation/pstate-core/core.ipynb
kernel_name: python3
has_widgets: false
title: 'pState Documentation'
prev_page:
  url: /examples/examples
  title: 'Examples'
next_page:
  url: /documentation/pstate-core/core
  title: 'Core'
comment: "***PROGRAMMATICALLY GENERATED, DO NOT EDIT. SEE ORIGINAL FILES IN /content***"
---


# The pState Core

**Spencer Park and Emil Sekerinski, July 2018**



_PCharts_ are a visual formalism for the design and analysis of embedded systems; _pState_ is a tool for working with pCharts. The predecessor, _iState_, used a LaTeX-based input format for charts and generated code for B and Pascal ([Sekerinski and Zurob 2001](https://dx.doi.org/10.1007/3-540-45441-1_28), [Sekerinski and Zurob 2002](https://dx.doi.org/10.1007/3-540-47884-1_8)); the correctness of charts is expressed through _state invariants_ ([Sekerinski 2009](https://10.1002/9780470522622.ch13)). Based on that work, pState was designed with a new Java-based user interface and added timing and probabilities to charts, hence the name _pState_ ([Nokovic and Sekerinski 2013](https://dx.doi.org/10.1109/MECO.2013.6601339), [Nokovic and Sekerinski 2014](https://dx.doi.org/10.1145/2641483.2641522)). Code generation was extended to C and PIC microcontrollers ([Nokovic and Sekerinski 2017](http://dx.doi.org/10.1007/978-3-319-47307-9_7)) and includes (for PIC) worst-case execution time analysis ([Nokovic and Sekerinski 2015](http://dx.doi.org/10.14279/tuj.eceasst.72.1026)). The analysis of charts was further extended with quantitative analysis and makes use of a probabilistic model checker to this end ([Nokovic and Sekerinski 2015](10.4204/EPTCS.187.6))

The current implementation of pState is a redevelopment with two goals:

1. to decouple the user interface from the analysis of charts by using modern Web-based techniques, such that the computationally intensive analysis can also run remotely, and
2. to simplify and generalize the implementation in order to ease further development, in particular for more code generators and alternative verification and quantitative analysis tools.

The current implementation consists of:

- a _web-based client_, maintained at https://gitlab.cas.mcmaster.ca/lime/pstate-client,
- the _core backend_, maintained at https://gitlab.cas.mcmaster.ca/lime/pstate-jupyter.

The user guide is documented elsewhere [add link]. This document, a Jupyter notebook, describes the core backend. This is an example of _literate development:_ the executable Python code for the backend is extracted from this notebook.



<h1>Table of Contents<span class="tocSkip"></span></h1>
<div class="toc"><ul class="toc-item"><li><span><a href="#Architecture-of-pState" data-toc-modified-id="Architecture-of-pState-1"><span class="toc-item-num">1&nbsp;&nbsp;</span>Architecture of pState</a></span></li><li><span><a href="#Terminology-and-Modularization" data-toc-modified-id="Terminology-and-Modularization-2"><span class="toc-item-num">2&nbsp;&nbsp;</span>Terminology and Modularization</a></span></li><li><span><a href="#The--Structure-of-Charts" data-toc-modified-id="The--Structure-of-Charts-3"><span class="toc-item-num">3&nbsp;&nbsp;</span>The  Structure of Charts</a></span><ul class="toc-item"><li><span><a href="#Chart-Types" data-toc-modified-id="Chart-Types-3.1"><span class="toc-item-num">3.1&nbsp;&nbsp;</span>Chart Types</a></span></li><li><span><a href="#Chart-States" data-toc-modified-id="Chart-States-3.2"><span class="toc-item-num">3.2&nbsp;&nbsp;</span>Chart States</a></span></li><li><span><a href="#Chart-Transitions" data-toc-modified-id="Chart-Transitions-3.3"><span class="toc-item-num">3.3&nbsp;&nbsp;</span>Chart Transitions</a></span></li><li><span><a href="#Chart-Statements" data-toc-modified-id="Chart-Statements-3.4"><span class="toc-item-num">3.4&nbsp;&nbsp;</span>Chart Statements</a></span></li><li><span><a href="#Chart-Expressions" data-toc-modified-id="Chart-Expressions-3.5"><span class="toc-item-num">3.5&nbsp;&nbsp;</span>Chart Expressions</a></span></li><li><span><a href="#PCharts" data-toc-modified-id="PCharts-3.6"><span class="toc-item-num">3.6&nbsp;&nbsp;</span>PCharts</a></span></li></ul></li><li><span><a href="#Expressions" data-toc-modified-id="Expressions-4"><span class="toc-item-num">4&nbsp;&nbsp;</span>Expressions</a></span></li><li><span><a href="#Statements" data-toc-modified-id="Statements-5"><span class="toc-item-num">5&nbsp;&nbsp;</span>Statements</a></span></li><li><span><a href="#Parsing-Labels" data-toc-modified-id="Parsing-Labels-6"><span class="toc-item-num">6&nbsp;&nbsp;</span>Parsing Labels</a></span><ul class="toc-item"><li><span><a href="#Scanning-Labels" data-toc-modified-id="Scanning-Labels-6.1"><span class="toc-item-num">6.1&nbsp;&nbsp;</span>Scanning Labels</a></span></li><li><span><a href="#Parsing-Types" data-toc-modified-id="Parsing-Types-6.2"><span class="toc-item-num">6.2&nbsp;&nbsp;</span>Parsing Types</a></span></li><li><span><a href="#Parsing-Expressions" data-toc-modified-id="Parsing-Expressions-6.3"><span class="toc-item-num">6.3&nbsp;&nbsp;</span>Parsing Expressions</a></span></li><li><span><a href="#Parsing-Statements" data-toc-modified-id="Parsing-Statements-6.4"><span class="toc-item-num">6.4&nbsp;&nbsp;</span>Parsing Statements</a></span></li><li><span><a href="#Parsing-State-Labels" data-toc-modified-id="Parsing-State-Labels-6.5"><span class="toc-item-num">6.5&nbsp;&nbsp;</span>Parsing State Labels</a></span></li><li><span><a href="#Parsing-Connection-Labels" data-toc-modified-id="Parsing-Connection-Labels-6.6"><span class="toc-item-num">6.6&nbsp;&nbsp;</span>Parsing Connection Labels</a></span></li></ul></li><li><span><a href="#Generating-the-Intermediate-Representation" data-toc-modified-id="Generating-the-Intermediate-Representation-7"><span class="toc-item-num">7&nbsp;&nbsp;</span>Generating the Intermediate Representation</a></span><ul class="toc-item"><li><span><a href="#Intermediate-Representation-and-Transition-Systems" data-toc-modified-id="Intermediate-Representation-and-Transition-Systems-7.1"><span class="toc-item-num">7.1&nbsp;&nbsp;</span>Intermediate Representation and Transition Systems</a></span></li><li><span><a href="#Generating-Unique-Names" data-toc-modified-id="Generating-Unique-Names-7.2"><span class="toc-item-num">7.2&nbsp;&nbsp;</span>Generating Unique Names</a></span></li><li><span><a href="#Generating-Intermediate-Code" data-toc-modified-id="Generating-Intermediate-Code-7.3"><span class="toc-item-num">7.3&nbsp;&nbsp;</span>Generating Intermediate Code</a></span></li></ul></li><li><span><a href="#Converting-State-Graphs-to-Charts" data-toc-modified-id="Converting-State-Graphs-to-Charts-8"><span class="toc-item-num">8&nbsp;&nbsp;</span>Converting State Graphs to Charts</a></span></li><li><span><a href="#Accumulating-Invariants" data-toc-modified-id="Accumulating-Invariants-9"><span class="toc-item-num">9&nbsp;&nbsp;</span>Accumulating Invariants</a></span></li><li><span><a href="#Well-Formedness-of-Charts" data-toc-modified-id="Well-Formedness-of-Charts-10"><span class="toc-item-num">10&nbsp;&nbsp;</span>Well-Formedness of Charts</a></span></li><li><span><a href="#Well-Definedness-of-Transition-Expressions" data-toc-modified-id="Well-Definedness-of-Transition-Expressions-11"><span class="toc-item-num">11&nbsp;&nbsp;</span>Well-Definedness of Transition Expressions</a></span></li><li><span><a href="#Statement-Correctness" data-toc-modified-id="Statement-Correctness-12"><span class="toc-item-num">12&nbsp;&nbsp;</span>Statement Correctness</a></span></li><li><span><a href="#Chart-Correctness" data-toc-modified-id="Chart-Correctness-13"><span class="toc-item-num">13&nbsp;&nbsp;</span>Chart Correctness</a></span></li><li><span><a href="#Adding-Costs" data-toc-modified-id="Adding-Costs-14"><span class="toc-item-num">14&nbsp;&nbsp;</span>Adding Costs</a></span></li><li><span><a href="#Type-checking-the-pState-Core" data-toc-modified-id="Type-checking-the-pState-Core-15"><span class="toc-item-num">15&nbsp;&nbsp;</span>Type-checking the pState Core</a></span></li><li><span><a href="#References" data-toc-modified-id="References-16"><span class="toc-item-num">16&nbsp;&nbsp;</span>References</a></span></li><li><span><a href="#Alternative-Implementations" data-toc-modified-id="Alternative-Implementations-17"><span class="toc-item-num">17&nbsp;&nbsp;</span>Alternative Implementations</a></span></li></ul></div>



## Architecture of pState



[Jupyter notebooks](http://jupyter.org/) are a document format that interleave prose in [markdown cells](http://jupyter-notebook.readthedocs.io/en/stable/examples/Notebook/Working%20With%20Markdown%20Cells.html), code cells, and code execution results. Notebooks, including the code execution results, are stored in [JSON files](https://www.json.org/). The Jupyter _kernel_ executes the code cells. Kernels for [various languages](https://github.com/jupyter/jupyter/wiki/Jupyter-kernels) exist; here we use Jupyter's standard Python kernel. All interaction with pState is done programmatically through Jupyter notebooks: for example, creating a pChart is done by creating a pChart object in Python; displaying a pChart opens an interactive editor for the chart; code for a pChart is generated by calling the corresponding method of the pChart object.

Overall, pState consists of:

- a _frontend_ with a web-based _pState client_ that integrates in Jupyter notebooks, and
- a _backend_, consisting of a Jupyter Server, a Python kernel for Jupyter, and the _pState backend_.

The pState backend consists of:

- _code generators_ targeting specific processors and programming languages, and
- the _core_, which interfaces to the code generators, Jupyter notebooks, and _external tools_ for verification.

![The pState Architecture](pStateArchitecture.svg)

The Jupyter server interacts with the file system to store notebooks. Communication between the frontend and the server is done via HTTP requests/responses. A frontend may also request the creation of a kernel and the server has the responsibility of spawning the appropriate kernel process and providing it with connection details so that the kernel and frontend can connect directly with WebSockets, rather than HTTP.

The Jupyter notebook frontend provides the graphical user interface for viewing and editing the notebook prose and code. When connected to a kernel it may also send a code cell to the kernel for execution. The result is sent to the frontend and displayed. The Jupyter notebook frontend supports rendering image formats such as PNG, JPEG, and SVG, as well as richer formats including LaTeX equations, HTML, and JavaScript.

The Jupyter notebook frontend loads the _pState client_, which is a web application written in [TypeScript](https://www.typescriptlang.org/). The client is compiled to JavaScript to run in a browser, and built on the [React](https://reactjs.org/) and [Redux](https://redux.js.org/) frameworks. When a chart is being edited, the pState client keeps a copy of the chart. When the chart changes, React renders a virtual view of the changed chart, compares it to the "concrete view", and makes the necessary changes to the concrete view so that it matches the virtual view. The concrete view is an HTML element with inline SVG for most of the chart drawing.


The pState backend is a Python library that lives in the kernel, as the programmatic pState interface is used through notebooks. Code written in the notebook is sent to the Python kernel for execution through WebSockets. This includes method calls to chart objects for analysis and compilation. The pState client is connected to the pState backend via the Jupyter messaging protocol's `comm` messages. These are sent asynchronously over WebSockets. The pState core sends chart updates, chart errors, and analysis results to the pState client to display to the user. The pState client sends chart updates to the pState Core.

The pState core receives a "raw chart", called a _state graph_ in JSON format, from the pState Client. The format is the same as used for storing charts in files. The tasks of the pState Core are:

- analyzing the well-formedness of charts,
- generating intermediate code,
- analyzing charts for correctness,
- quantitatively analyzing charts,
- animating charts.

For this, the pState Core uses two external tools:

- an SMT solver for checking (1) the well-formedness of conditionals in transitions, (2) the definedness of expressions in transitions, and (3) the correctness of transitions with respect to state invariants
- a probabilistic model checker for quantitative analysis: (1) the probabilities of reaching a state, (2) the cost in terms of transitions for reaching a state, and (3) the cost in terms of durations in stays in states.

The rest of this notebook documents the pState core. Code generators are documented in separate notebooks.

Missing:
- interpretation of pCharts
- cost queries



## Terminology and Modularization
![The pState Core Modularization](pStateCoreModularization.svg)



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
from dataclasses import dataclass, field, MISSING
from fractions import Fraction
from typing import NamedTuple, Tuple, Union, Optional, Text, MutableMapping, Sequence, Set, \
    MutableSet, Generator, Iterable, Collection

```
</div>

</div>



The pState core receives chart updates from the client. When analzing a chart, the core deals with three kinds of issues:

* **errors**: when the chart is not well-formed and intermediate code cannot be generated
* **alerts**: when the chart is structurally well-formed and intermediate code can be generated, but the analysis reports flaws in the design
* **warnings**: when the chart is structurally well-formed and intermediate code can be generated, but the analysis fails to establish the absence of flaws in the design due to limitations of the analysis

The pState client gets back a list with errors, alerts, and warnings, to display them accordingly. Internally in the backend, a class derived from `Exception` is used for each kind of issue:



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
from abc import ABCMeta, abstractmethod


class ChartException(Exception, metaclass=ABCMeta):
    @property
    @abstractmethod
    def msgs(self) -> Sequence['ChartMessage']:
        pass

    @abstractmethod
    def to_json(self):
        pass


class ChartMessage(ChartException):
    @property
    def msgs(self) -> Sequence['ChartMessage']:
        return (self,)

    def __init__(self, kind, message, target=None):
        self.kind, self.message = kind, message
        self.target = target.id if hasattr(target, 'id') else target

    def to_json(self):
        json = {'kind': self.kind, 'message': self.message}
        if self.target is not None: json['target'] = self.target
        return json


class ChartMessages(ChartException):
    @property
    def msgs(self) -> Sequence['ChartMessage']:
        return self._msgs

    def __init__(self, *exceptions: ChartException):
        self._msgs = [msg for exception in exceptions for msg in exception.msgs]

    def to_json(self):
        return list(map(ChartException.to_json, self.msgs))


class Error(ChartMessage):
    def __init__(self, message, target=None):
        super().__init__('error', message, target)


class Alert(ChartMessage):
    def __init__(self, message, target=None):
        super().__init__('alert', message, target)


class Warning(ChartMessage):
    def __init__(self, message, target=None):
        super().__init__('warning', message, target)

```
</div>

</div>



EBNF is used to specify the abstract and concrete grammar of charts:

- Nonterminals start with an upper case letter
- Terminals start with a lower case cetter or are written in quotes
- Productions are written as `A ::= E`
- `E | F` means `E` or `F`
- `[E]` means `E` optional
- `{E}` means `E` repeated zero or more times

In charts, labels can be attached to states and transitions. Labels are parsed by recursive descent. In case of a parsing error, parsing is aborted by raising an `Error`, the error message is collected, and parsing of another label may continue.



- abstract vs concrete grammar
- partial functions
- procedure, method, function, function procedure, function method, partial function



## The  Structure of Charts



### Chart Types



Every _chart expression_ has a unique _type:_ _integer_, _boolean_, _fraction_, _function_, or _set_. _Chart variables_ have to be declared to be either an _integer subrange_, boolean, function, or set; that is, variables cannot be declared of type integer, only integer subrange. Fractional numbers are used only for constants, not for variables:

| Type       | Notation       | Values
|:-----------|:---------------|:-----
| integer    |`integer`       | all integer values, without upper or lower bound
| subrange   |`a ‥ b`         | integers from `a` to `b` inclusive, provided `a ≤ b`
| boolean    |`bool`          | `true` and `false`
| fraction   |                | pairs of integers, the nominator and denominator, with positive denominator
| product    |`t₁ × t₂ × ⋯`   | tuples `v₁, v₂, …` with each `vᵢ` of type `tᵢ`
| function   |`t → u`         | functions from type `t` to type `u`; type `t` must consist only of subrange, boolean, and product types
| set        | `set t`        | all sets `{v₁, v₂, …}` where `vᵢ ∈ t`; type `t` must be a subrange with less than 256 values or `bool`

Function types can be used to represent arrays, but are more general in that they don't require that indexing starts at 0 and allow booleans as arguments; function types with a product as the domain can be used to represent multi-dimensional arrays. Examples:

    0 ‥ N - 1 → bool
    3 ‥ 9 × bool → set 0 ‥ 9

Value `v` is of type `t` is written as `v : t`. Examples:

    8, true : integer × bool
    {0, 5} : set integer

Above, `{0, 5}` is the set consisting of `0` and `5`, not the set consisting of the tuple `0, 5`; sets of tuples are not allowed.

**Representation.** Types are represented by `Type` objects with the `kind` field being the `Kind` instance with value `integer`, `bool`, `fraction`, `set`, `‥`, `×`, or `→`. The `arg` field is a list with the arguments of the type constructor, if any. For example, `3 ‥ 9` is represented by `Type('‥', 3, 9)` and `bool → bool` by `Type('→', Type('bool'), Type('bool')])`.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
from enum import Enum


class Kind(Enum):
    INTEGER = 'integer', lambda x: x == 0
    SUBRANGE = '‥', lambda x: x == 2
    BOOLEAN = 'bool', lambda x: x == 0
    FRACTION = 'fraction', lambda x: x == 2
    PRODUCT = '×', lambda x: x >= 2
    FUNCTION = '→', lambda x: x == 2
    SET = 'set', lambda x: x == 1

    def __new__(cls, name, arity):
        kind = object.__new__(cls)
        kind._value_ = name
        kind.arity = arity
        return kind

    def __str__(self):
        return self.value


@dataclass
class Type:
    kind: Kind
    args: Tuple[Union['Type', 'Expression'], ...]

    def __init__(self, kind: Union[Text, Kind], *args: Union['Type', 'Expression']):
        self.kind = kind if isinstance(kind, Kind) else Kind(kind)
        self.args = args
        assert self.kind.arity(len(args))

    def __str__(self):
        if self.kind in (Kind.SUBRANGE, Kind.FUNCTION):
            return '%s %s %s' % (self.args[0], self.kind, self.args[1])
        elif self.kind == Kind.PRODUCT:
            return ' × '.join(
                ('[%s]' if arg.kind in {Kind.PRODUCT, Kind.FUNCTION} else '%s') % arg for arg in self.args)
        elif self.kind == Kind.SET:
            return 'set ' + ('[%s]' if self.args[0].kind in {Kind.PRODUCT, Kind.FUNCTION} else '%s') % self.args[0]
        else:
            return str(self.kind)  # integer, boolean, fraction


assert str(Type('→', Type('×', Type('‥', 3, 9), Type('bool')), Type('set', Type('‥', 0, 9)))) == \
       '3 ‥ 9 × bool → set 0 ‥ 9'
assert str(Type('→', Type('integer'), Type('×', Type('bool'), Type('integer')))) == 'integer → bool × integer'
assert str(Type('×', Type('→', Type('integer'), Type('bool')), Type('integer'))) == '[integer → bool] × integer'
assert str(Type('×', Type('integer'), Type('→', Type('bool'), Type('integer')))) == 'integer × [bool → integer]'

```
</div>

</div>



Pretty-printing assumes that `×` binds tighter than `→`, that `→` associates to the right, and that `→` cannot appear as the first argument of `→`. Thus brackets need only to be printed around each argument of `×` if the argument itself is either `×` or `→`.



### Chart States



The definition of _chart states_ is as follows. Let `Variable`, `Event`, `Cost` be the _variable_, _event_, and _cost names_, let `Basic`, `And`, `Xor` be finite and mutually disjoint sets of state names, and let `State = Basic ∪ Xor ∪ And` be the set of all states. The state `root` is a dedicated `Xor` state:

    root ∈ Xor
    parent : State \ {root} → State
    var : State → (Variable ⇸ Type)
    ev : State → set Event
    inv : State → Expression
    cost : State → (Cost ⇸ Expression)
    init : Xor ⇸ set Conditional

Some restrictions apply:
- With the `parent` function, states must form a tree that is rooted in `root`.
- Expressions of `inv` must be of boolean type.
- Expressions of `cost` must be of fraction type.

**Representation.** A state is represented by an object of class `State`, with fields corresponding to the functions above and several additional fields:
- field `id` of type `str`, which is a unique id among all states and transitions, for associating states to error messages,
- field `children` of type `set`, such that `c.parent == s` for all `c` of `s.children` and all states `s`; this field facilitates traversal of all states,
- field `name` of type `str`, for referring to the state in state tests,
- fields `unique_name` and `unique_vars` for uniquely naming states and variables in a "flat" representation of states,
- field `const`, a mapping of `str` objects, the constant names, to values of chart types; named constants only serve for readability, they are eliminated in the intermediate code.

Members of the sets `Variable`, `Event`, and `Cost` are represented by `str` objects.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
Event = Text
Cost = Tuple['Expression', Optional[Text]]

INHERIT_NAME_FROM_ID = object()


@dataclass()
class State:
    id: Text
    parent: 'Optional[State]' = None
    children: 'MutableSet[State]' = field(default_factory=set, init=False)
    name: Optional[Text] = INHERIT_NAME_FROM_ID
    const: 'MutableMapping[Text, ConstNumberExpression]' = field(default_factory=dict)
    var: MutableMapping[Text, Type] = field(default_factory=dict)
    inv: 'Optional[Expression]' = None
    ev: MutableSet[Event] = field(default_factory=set)
    cost: MutableMapping[Text, Cost] = field(default_factory=dict)
    init: Set['Conditional'] = field(default_factory=set)
    unique_name: Optional[Text] = None
    unique_vars: Optional[MutableMapping[Text, Text]] = None  # unique_name -> declared name

    def __post_init__(self):
        if self.name is INHERIT_NAME_FROM_ID:
            self.name = self.id

        if self.parent is not None:
            self.parent.children.add(self)

    def __str__(self):
        return 'State(id=' + str(self.id) + \
               (', parent=' + str(self.parent.id) if self.parent else '') + \
               ', children=' + str(self.children) + \
               ', name=' + str(self.name) + \
               ', const=' + str(self.const) + \
               ', var=' + str({v: str(self.var[v]) for v in self.var}) + \
               (', inv=' + str(self.inv) if self.inv else '') + \
               ', ev=' + str(self.ev) + \
               ', cost=' + str({c: (str(self.cost[c][0]), str(self.cost[c][1])) for c in self.cost}) + \
               ', init=' + str(self.init) + \
               (', unique_name=' + str(self.unique_name) if self.unique_name is not None else '') + ')'

    def __repr__(self):
        return 'State(id=' + str(self.id) + ', ...)'

    def __hash__(self):
        return hash(self.id)

    def print_hierarchy(self, prefer_unique=False, indent=2, depth=0) -> Text:
        if prefer_unique and self.unique_vars:
            variables = map(lambda ud: (ud[0], self.var[ud[1]]), self.unique_vars.items())
        else:
            variables = self.var.items()
        variables_msg = ', '.join('%s:%s' % (name, typ) for name, typ in variables)
        if len(variables_msg) > 0:
            variables_msg = '|' + variables_msg

        msg = depth * indent * ' ' + ((prefer_unique and self.unique_name) or self.name or '_') + variables_msg
        for child in self.children:
            msg += '\n' + child.print_hierarchy(prefer_unique=prefer_unique, indent=indent, depth=depth + 1)
        return msg

    def siblings(self, reflexive=False) -> Generator['State', None, None]:
        if self.parent is None:
            return
        for s in self.parent.children:
            if reflexive or s.id != self.id:
                yield s

```
</div>

</div>



### Chart Transitions



_Chart transitions_ are annotated connections between chart states. The _source_ of a transition is a single state. The _event_ of a transition is either a _named event_ or a _timing_. Named events are either _internally broadcast_ or _externally generated_. Each transition has a _guard_, may have _costs_, and has a statement (the _body of the transition_). The _target_ of a transition is a set of _probabilistic alternatives_, consisting of a _probability_, a statement (the _body of the probabilistic alternative_), and a set of _conditional choices_. In turn, conditional choices consist of a guard, a statement (the _body of of the conditional choice_), and a _target state_.

    source : Transition → State
    event : Transition → Event ∪ Timing
    guard : Transition → Expression
    cost : Transition → (Cost ⇸ Expression)
    body : Transition → Statement
    alt : Transition → set Alternative

    prob : Alternative → Fraction
    body : Alternative → Statement
    cond : Alternative → set Conditional

    guard : Conditional → Expression
    body : Conditional → Statement
    target : Conditional → State

Following restrictions hold:
- The guard must be an Boolean chart expression, to be made precise later.
- The statement of a transition, the statement of a probabilistic alternative, and the statement of a conditional choice must be chart statements and must be conflict free, as defined later.
- The probabilities of all alternatives of a transition must add up to `1`.
- The conditions of all conditionals must be _disjoint_, i.e. the pairwise conjunction must be `False`, and must _complete_, i.e. the disjunction of all must be `True`.
- Target states of a transition must either be siblings or the parent of the source state or must all be children of the source state.
- Initial target states of an Xor state must all be children of the state.

**Representation.** Each transition is represented by an object of the class `Transition`, with fields corresponding to the functions above and one additional field:
- field `id` of type `str`, which is a unique id among all transitions and is used for associating transitions to error messages.

Alternatives and conditionals are represented by triples.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
class Transition:
    def __init__(self, id: Text, source: State, event: Union[Event, 'Timing'], guard: 'Expression',
                 cost: MutableMapping[Text, Cost], body: 'Statement', alt: 'Set[Alternative]'):
        self.id, self.source, self.event, self.guard, self.cost, self.body, self.alt = \
            id, source, event, guard, cost, body, alt

    def __str__(self):
        return 'Transition(source=' + repr(self.source) + \
               ' event=' + str(self.event) + \
               (' guard=' + str(self.guard) if self.guard else '') + \
               ' cost=' + str(self.cost) + \
               ' body=' + str(self.body) + \
               ' alt=' + str([[str(alt.prob), str(alt.body), [[str(cond.guard), str(cond.body), repr(cond.target)]
                                                              for cond in alt.cond]] for alt in self.alt]) + ')'

    def __repr__(self):
        return 'Transition(id=' + str(self.id) + ', ...)'


class Alternative(NamedTuple):
    prob: Fraction
    body: 'Statement'
    cond: 'Set[Conditional]'


class Conditional(NamedTuple):
    guard: 'Expression'
    body: 'Statement'
    target: 'State'


def cond_always(target: 'State'):
    return Conditional(True, skip, target)

```
</div>

</div>



The timing of a timed transition specifies when the transition is _scheduled_. Times are fractional numbers for the time in seconds:

| Timing      | Notation       | Schedule                                               |
| :---------- | :------------- | :----------------------------------------------------- |
| between     | `t₀‥t₁`        | nondeterministically between `t₀` and `t₁`, including  |
| before      | `‥t₁`          | before or at `t₁`; shorthand for `0‥t₁`                |
| at          | `t₀`           | at time `t₀`; shorthand for `t₀‥t₀`                    |
| after       | `t₀‥`          | at or after `t₀`                                       |
| exponential | `exp(t)`       | exponentially distributed with a mean of `t`           |
| uniform     | `unif(t₀, t₁)` | uniformly distributed between `t₀` and `t₁`, including |

**Representation.** Time is represented by non-negative `Fraction` values in seconds. A timing is represented by a `Timing` instance. For example, `Timing(TimingKind.BETWEEN, 0, 9)` is a timing for scheduling before `9s` and `Timing(TimingKind.EXPONENTIAL, Fraction(3, 2))` stands for an exponential distribution with a mean of `1.5 s` (or equivalently with rate parameter λ = ⅔).



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
class TimingKind(Enum):
    BETWEEN = 'between', lambda t0, t1: t0 is not None or t1 is not None
    EXPONENTIAL = 'exp', lambda t0, t1: t0 is not None and t1 is None
    UNIFORM = 'unif', lambda t0, t1: t0 is not None and t1 is not None

    def __new__(cls, name, validate_args):
        kind = object.__new__(cls)
        kind._value_ = name
        kind.validate_args = validate_args
        return kind

    def __str__(self):
        return self.value


@dataclass
class Timing:
    kind: TimingKind
    t0: Optional['ConstNumberExpression'] = None
    t1: Optional['ConstNumberExpression'] = None

    def __init__(self, kind: Union[Text, TimingKind], t0: Optional['ConstNumberExpression'] = None,
                 t1: Optional['ConstNumberExpression'] = None):
        self.kind = kind if isinstance(kind, TimingKind) else TimingKind(kind)
        self.t0, self.t1 = Fraction(t0) if t0 is not None else None, Fraction(t1) if t1 is not None else None
        assert self.kind.validate_args(t0, t1)

    def __str__(self):
        if self.kind == TimingKind.BETWEEN:
            if self.t0 == self.t1:
                return str(self.t0)
            elif self.t0 is None:
                return '‥' + str(self.t1)
            elif self.t1 is None:
                return '‥' + str(self.t0)
            else:
                return str(self.t0) + '‥' + str(self.t1)
        elif self.kind == TimingKind.EXPONENTIAL:
            return 'exp(%s)' % self.t0
        elif self.kind == TimingKind.UNIFORM:
            return 'unif(%s, %s)' % (self.t0, self.t1)

```
</div>

</div>



### Chart Statements



A _chart statement_ is one of the following:

| Statement             | Notation             | Effect
|:----------------------|:---------------------| :-------------
| Assignment            | `x ≔ e`              | evaluate expression `e` and assign to designator `x`
| Parallel Composition  | `s ‖ t`              | simultaneously execute statements `s` and `t`
| Conditional Statement | `if b then s else t` | if Boolean expression `b` is true, execute `s`, otherwise `t`
| Broadcast             | `E`                  | broadcast event `E` to all concurrent states

In an _assignment_, the expression and designator have to be of the same base type. If the designator is declared to be of a subrange type, the expression has to be subsumed in that range. Tuple composition is considered to be associative, so `(t × u) × v` is the same as `t × u × v`. For example, given the declaration `a: 2..7 → bool × bool, b, c: bool, d: 3..6`, following assignment is correctly typed:

    b, c, d ≔ a(3), 4

The parallel composition of assignments is equivalent to a single assignment:

     x ≔ e ‖ y ≔ f   ＝   x, y ≔ e, f

A conditional statement assigning to the same variables can be merged into a single assignment with a conditional expression:

    if b then x ≔ e else x ≔ f   ＝   x ≔ b ? e : f

An assignment of value to a function argument is equivalent to updating the function:

    x(e) ≔ f  =  x ≔ (i • i = e ? f : x(i))

> The parallel composition of assignments to function values of the same function is equivalent to a multiple update:
>
>     x(e1) ≔ f1 ‖ x(e2) ≔ f2   ＝   x ≔ x(e1, e2 ← f1, f2)

Assuming that multiple assignments are eliminated using this rule, following restrictions must hold for assignments and their parallel composition:
- the variables to be assigned have to be _assignable_, meaning that they have to be declared in the scope of the transition or in an ancestor; the declaration closest to the scope is taken
- in assignments to function values, the argument has to be in the domain of the function and the value has to be in the range.
- in parallel compositions of assignments, the assigned variables have to be distinct or; in case of assignments to functions arguments, the same function can be assigned, but the arguments have to be different.

The restrictions on statements and the representation of statements is given later.



### Chart Expressions



A _chart expression_ is one of the following:

| Expression            | Notation                  | Result
|:----------------------|:--------------------------|:---------------------------------------------------
| constant              | `0`, `1`, ...             | integer `0`, `1`, ...
|                       | `m.n`                     | fraction `m.n` for integers `m`, `n`
|                       | `true`, `false`           | boolean `true`, `false`
| designator            | `x`                       | identifier `x` for constant, variable, state, event
|                       | `S.x`, `T.S.x`            | identifier `x` in state `S`, state `T.S`
|                       | `f(e)`                    | function `f` applied to `e`
|                       | `e, f,` ...               | tuple with `e`, `f`, ...
| unary operations      | `- e`                     | minus `e`
|                       | `¬ e`                     | not `e`
|                       | `∑ e`, `∏ e`              | sum, product of `e`
|                       | `min e`, `max e`          | minimum, maximum of `e`
|                       | `all e`, `any e`          | all elements of `e` are true, at least one is true
|                       | `some e`                  | arbitrary element of `e`
|                       | `# e`                     | cardinality of `e`
|                       | `eⁿ`                      | exponentiation of `e` with integer `n`
| state test            | `in S`, `in T.S`          | in concurrent state `S`, descendant `S` of `T`, ...
| binary operations     | `e + f`, `e − f`, `e × f` | sum, difference, product
|                       | `e / f`                   | fractional division
|                       | `e div f`, `e mod f`      | integer division and modulo
|                       | `e ∧ f`, `e ∨ f`          | conjunction and disjunction
|                       | `e ⇒ f`, `e ⇐ f`, `e ≡ f`, `e ≢ f`| implication, consequence, equivalence, disequivalence
|                       | `e = f`, `e ≠ f`          | equality, disequality
|                       | `e < f`, `e ≤ f`, `e > f`, `e ≥ f`| less than, less than or equal, greater than, greater than or equal
|                       | `e ∈ f`, `e ∉ f`          | member, not member
|                       | `e ⊂ f`, `e ⊆ f`, `e ⊃ f`, `e ⊇ f`, | subset or equal, superset or equal, subset, superset
|                       | `e ∩ f`, `e ∪ f`, `e \ f` | intersection, union, difference
| conditional operation | `e ? f : g`               | if `e` then `f` else `g`
| interval              | `e ‥ f`                   | set with `e`, `e + 1`, ..., `f`
| set enumeration       | `{e₁, e₂,` ...`}`         | set with `e₁`, `e₂`, ...
| set comprehension     | `{e ∣ i ∈ r, b}`          | set of `e` for `i ∈ r` where `b`
| comprehension         | `(e ∣ i ∈ r, b)`          | `e` for given `i ∈ r` if `b`

(_Note:_ as `|` with code point U+007C cannot be used in tables, `∣` (divides) with code point U+2223 is used above.)

Comprehensions can be used with unary `sum`, `prod`, `min`, `max`, `all`, `any`, `some`:

    sum(i² | i ∈ 0 ‥ N - 1)                 ∑(i² | i ∈ 0 ‥ N - 1)
    prod(abs(i) | i ∈ {1, 1, 2, 3, 5})      ∏(abs(i) | i ∈ {1, 1, 2, 3, 5})

Comprehensions are a more convenient notation for lambda abstraction generalized to allow a condition on the parameter:

    (e ∣ i ∈ r, b)  =  i ∈ r, b • e

The condition `b` is understood to be `true` if left out. The range `r` is comprises all elements of the corresponding type if left out. Formally, the generalized lambda abstraction `i ∈ r, b • e` is a pair with the first component a function defining the domain and the second component a function returning `e` within the domain and an arbitrary value outside the domain:

    i ∈ r, b • e  =  (d, v) where d = λ i • i ∈ r ∧ b and v = λ i • (ε x • d x ∧ x = e))

A set `s` is a Boolean-valued function and `x ∈ s` stands for `s x`. Thus:

    {e | i ∈ r, b}  =  set(d, v)  =  λ x • (∃ i • d i ∧ x = v i)

Comprehensions can be used in charts but are also used internally to represent function modifications:

               x(e) ≔ f  =  x ≔ (i • i = e ? f : x(i))
    x(i) ≔ f | i ∈ r, b  =  x ≔ (i • i ∈ r ∧ b ? f : x(i))
    x(e) ≔ f | i ∈ r, b  =  x ≔ (j • any(j = e | i ∈ r, b) ? some(f | i ∈ r, j = e ∧ b) : x(j))

The representation is specified later. The concrete grammar defines operator precedences and standard functions; the concrete grammar is specified with the parsing procedures.



## Expressions



**Representation.** Integers are represented by `int` objects. Fractions are represented by `Fraction` objects. Booleans are represented by `True` and `False`. Identifiers for variables, constants, states, and events are represented by `str` objects; qualified identifiers are represented by `str` objects with `.` separating the identifiers. Function applications are represented by `Application` objects with the function and the argument.

Tuples are represented by `tuple` objects. Unary operations are represented by `Application` objects with the string `⊖`, `¬`, `min`, `max`, `all`, `any`, `some`, `∑`, `∏`, `#`, `in`, or superscripts `⁰`, ..., `⁹` for the function and the operand as the argument. Binary operations that are non-associative and non-commutative are represented by `Application` objects with the string `−`, `/`, `div`, `mod`, `⇒`, `⇐`, `=`, `≠`, `≤`, `≥`, `<`, `>`, `∈`, `∉`, `⊆`, `⊇`, `⊂`, `⊃`, `\` as the function and a pair (a `tuple` with two elements) as the argument. Associative and commutative binary operations are represented by `Application` objects with the string `+`, `×`, `∧`, `∨`, `≡`, `∩`, `∪` as the function and a tuple with at least two elements as the argument. Note that `⊖` represents the unary minus and `-` the binary minus, but both are printed as `-`. Conditional operations are represented by `Application` objects with `?` as the function and a triple (a `tuple` with three elements) as the argument. Set enumerations are represented by `Application` objects with `{}` as the function and a tuple with the set elements as the argument. Intervals are represented by `Application` objects with `‥` as the function name and a pair with the two bounds as the argument. Comprehensions are represented by `Abstraction` objects. Set comprehensions are represented as applications of a unary operator, `set` to an abstraction object, as illustrated by:

    {e ∣ i ∈ r, b}  =  set(e ∣ i ∈ r, b)  =  set(i ∈ r, b • e)

TODO Check superscript exponentiation



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
PrefixOp = {'⊖', '¬', '#', 'in', 'min', 'max', 'all', 'any', 'some', '∑', '∏', 'set'}
NonAssocCommOp = {',', '-', '/', 'div', 'mod', '⇒', '⇐', '≡', '≢', '=', '≠', '≤', '≥', '<', '>',
                  '∈', '∉', '⊆', '⊇', '⊂', '⊃', '\\', '‥'}
AssocCommmOp = {'+', '×', '∧', '∨', '∩', '∪', '{}'}


# additionally tertiary '?', set comprehension `set`

class Application(NamedTuple):
    fn: Text
    arg: Union['Expression', Sequence['Expression']]

    def __eq__(self, other):
        return isinstance(other, Application) and self.fn == other.fn and \
               ((self.fn in AssocCommmOp and all(
                   self.arg.count(a) == other.arg.count(a) for a in self.arg)) or self.arg == other.arg)

    def __str__(self):
        if self.fn in PrefixOp:
            return ('-' if self.fn == '⊖' else self.fn) + ' ' + str(self.arg)
        elif self.fn == '{}':
            return '{' + ', '.join(nstr(a) for a in self.arg) + '}'
        elif self.fn == ',':
            return ', '.join(nstr(a) for a in self.arg)
        elif self.fn in NonAssocCommOp | AssocCommmOp:
            return '(' + (' ' + self.fn + ' ').join(str(a) for a in self.arg) + ')'
        elif self.fn == '?':
            return '(' + nstr(self.arg[0]) + ' ? ' + nstr(self.arg[1]) + ' : ' + nstr(self.arg[2]) + ')'
        else:
            return self.fn + str(self.arg)


class Abstraction(NamedTuple):
    var: Text
    range: Optional[Type]
    cond: Optional['Expression']
    body: 'Expression'

    def __str__(self):
        return '(' + self.var + (' ∈ ' + str(self.range) if self.range else '') + \
               ('' if self.cond is True else ', ' + nstr(self.cond)) + ' • ' + nstr(self.body) + ')'


Expression = Union[bool, int, Fraction, Text, Application, Abstraction]
ConstNumberExpression = Union[int, Fraction]


def nstr(e: Expression) -> str:
    """no parenthesis string: remove leading ( or [ and trailing ) or ], if present"""
    s = str(e)
    return s[1:-1] if s[0] in ('(', '[') else s

```
</div>

</div>



Equality on expressions is defined as syntactic equality modulo associativity and commutativity for `AssocCommmOp` operators:



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
e = Application('+', ('x', Application('×', ('y', 'z'))))
f = Application('+', (Application('×', ('z', 'y')), 'x'))
assert str(e) == '(x + (y × z))'
assert str(f) == '((z × y) + x)'
assert e == f

e, f = Application('{}', ('x', 'y')), Application('{}', ('x', 'z'))
assert str(e) == '{x, y}' and str(f) == '{x, z}'
assert e != f

e, f = Application('-', ('x', 'y')), Application('-', ('y', 'x'))
assert str(e) == '(x - y)' and str(f) == '(y - x)'
assert e != f

e = Application('-', ('x', Application('+', ('x', 'y'))))
f = Application('-', ('x', Application('+', ('y', 'x'))))
assert str(e) == '(x - (x + y))'
assert str(f) == '(x - (y + x))'
assert e == f

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def iterate_associative_op(op: Text, *exp: Expression) -> Generator[Expression, None, None]:
    for e in exp:
        if isinstance(e, Application) and e.fn == op:
            yield from iterate_associative_op(op, *e.arg if isinstance(e.arg, Iterable) else e.arg)
        else:
            yield e

def parent_transitive_closure(s: State, reflexive: bool=False, include_root: bool=True) -> Generator[State, None, None]:
    if include_root:
        if reflexive:
            yield s
        while s.parent is not None:
            yield s.parent
            s = s.parent
    else:
        if s.parent is None:
            return
        if reflexive:
            yield s
        s = s.parent # parent is not None from the above if statement
        while s.parent is not None:
            yield s
            s = s.parent

```
</div>

</div>



That is, if `e == f` is true, `e` and `f` are syntactically equal or are syntactically different but  semantically equal. If `==` is false, they are syntactically different but they may be semantically equal or different. The use of `==` is for simplification: for example conjunction `e ∧ f` is formed from `e` and `f` only if `e != f`, otherwise either `e` or `f` is taken.



For each operator, a function is defined for constructing the corresponding operator expression. These function also evaluate constant expressions and perform algebraic simplifications.

Function `negative(e)` constructs an object representing `-e`, for integer or fractional number `e`. Following simplifications are performed:

    --e  →  e
     -c  →  d    where d is -c for constant c



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def negative(e: Expression) -> Expression:
    if isinstance(e, (int, Fraction)):
        return -e
    elif isinstance(e, Application) and e.fn == '⊖':
        return e.arg
    else:
        return Application('⊖', e)


assert str(negative(3)) == '-3'
assert str(negative(negative(3))) == '3'
assert str(negative('x')) == '- x'

```
</div>

</div>



Function `negation(e)` constructs an object representing `¬e`, for boolean `e`. Following simplifications are performed:

    ¬true   →  false
    ¬false  →  true
       ¬¬e  →  e



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def negation(e: Expression) -> Expression:
    if isinstance(e, bool):
        return not e
    elif isinstance(e, Application) and e.fn == '¬':
        return e.arg
    else:
        return Application('¬', e)


assert str(negation(True)) == 'False'
assert str(negation(negation('x'))) == 'x'
assert str(negation('x')) == '¬ x'

```
</div>

</div>



Function `summation(e)` constructs an object representing `∑ e` for abstraction `e`. Following simplifications are performed:

    ∑ e | i ∈ r, b  →  0    if r = l ‥ u and l > u
    ∑ e | i ∈ r, b  →  0    if b = false

TODO add more simplifcations, e.g. if `r` has only one element or if `b` is false at the bounds of `r`



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def summation(e: Abstraction) -> Expression:
    assert e.range is not None and e.range.kind == Kind.SUBRANGE, 'Summation abstraction parameter type must be subrange.'

    if all(isinstance(arg, int) for arg in e.range.args) and e.range.args[0] > e.range.args[1]:
        return 0
    elif e.cond is False:
        return 0
    else:
        return Application('∑', e)


assert str(summation(Abstraction('i', Type('‥', 5, 3), True, 'i'))) == '0'
assert str(summation(Abstraction('i', Type('‥', 'a', 'b'), False, 'i'))) == '0'
assert str(summation(Abstraction('i', Type('‥', 'a', 'b'), True, 'i'))) == '∑ (i ∈ a ‥ b • i)'

```
</div>

</div>



Function `product(e)` constructs an object representing `∏ e` for abstraction `e`. Following simplifications are performed:

    ∏ e | i ∈ r, b  →  1    if r = l ‥ u and l > u
    ∏ e | i ∈ r, b  →  1    if b = false

TODO add more simplifcations, e.g. if `r` has only one element or if `b` is false at the bounds of `r`



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def product(e: Abstraction) -> Expression:
    assert e.range is not None and e.range.kind == Kind.SUBRANGE, 'Product abstraction parameter type must be subrange.'

    if all(isinstance(arg, int) for arg in e.range.args) and e.range.args[0] > e.range.args[1]:
        return 1
    elif e.cond is False:
        return 1
    else:
        return Application('∏', e)


assert str(product(Abstraction('i', Type('‥', 5, 3), True, 'i'))) == '1'
assert str(product(Abstraction('i', Type('‥', 'a', 'b'), False, 'i'))) == '1'
assert str(product(Abstraction('i', Type('‥', 'a', 'b'), True, 'i'))) == '∏ (i ∈ a ‥ b • i)'

```
</div>

</div>



Function `minimum(e)` constructs an object representing `min e` for set `e` of integer or fractional numbers. Following simplifications are performed if the argument is an enumerated set:

                   min {e}  →  e
    min {e, …, min {f, …}}  →  min {e, …, f, …}
             min {c, …, d}  →  min {…, d}    if c ≥ d for constants c, d

TODO The concrete syntax allows tuples to be used in lieu of set enumerations, with implicit conversion, allowing familiar notation as in `min(a, b)` OR change to infix operator, `a min b`



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def minimum(e: Expression) -> Expression:
    if isinstance(e, Application) and e.fn == '{}':  # set enumeration
        m, sa, oa = None, [], list(e.arg)  # minimum so far, simplified arguments, original arguments
        while oa:
            ei = oa.pop(0)
            if isinstance(ei, (int, Fraction)):
                if m is None:
                    sa.append(ei); m = ei
                elif m > ei:
                    sa.remove(m); sa.append(ei); m = ei
            elif isinstance(ei, Application) and ei.fn == 'min' and \
                    isinstance(ei.arg, Application) and ei.arg.fn == '{}':
                oa = list(ei.arg.arg) + oa
            elif ei not in sa:
                sa.append(ei)
        assert len(sa) > 0, 'min of empty collection'
        return sa[0] if len(sa) == 1 else Application('min', Application('{}', sa))
    else:
        return Application('min', e)  # other set expression


assert str(minimum(Application('∪', ('x', 'y')))) == 'min (x ∪ y)'

e = Application('{}', (3, 'x', Application('min', Application('{}', ('x', 4)))))
assert str(e) == '{3, x, min {x, 4}}'
assert str(minimum(e)) == 'min {3, x}'

e = Application('{}', (4, 3))
assert str(e) == '{4, 3}'
assert str(minimum(e)) == '3'

try:
    print(minimum(Application('{}', [])))
except Exception as m:
    assert str(m) == 'min of empty collection'

```
</div>

</div>



Function `maximum(e)` constructs an object representing `max e` for set `e` of integer or fractional numbers. Following simplifications are performed if the argument is an enumerated set:

                   max {e}  →  e
    max {e, …, max {f, …}}  →  max {e, …, f, …}
             max {c, …, d}  →  max {…, d}    if c ≤ d for constants c, d



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def maximum(e: Expression) -> Expression:
    if isinstance(e, Application) and e.fn == '{}':  # set enumeration
        m, sa, oa = None, [], list(e.arg)  # maximum so far, simplified arguments, original arguments
        while oa:
            ei = oa.pop(0)
            if isinstance(ei, (int, Fraction)):
                if m is None:
                    sa.append(ei); m = ei
                elif m < ei:
                    sa.remove(m); sa.append(ei); m = ei
            elif isinstance(ei, Application) and ei.fn == 'max' and \
                    isinstance(ei.arg, Application) and ei.arg.fn == '{}':
                oa = list(ei.arg.arg) + oa
            elif ei not in sa:
                sa.append(ei)
        assert len(sa) > 0, 'max of empty collection'
        return sa[0] if len(sa) == 1 else Application('max', Application('{}', sa))
    else:
        return Application('max', e)  # other set expression


assert str(maximum(Application('∪', ['x', 'y']))) == 'max (x ∪ y)'

e = Application('{}', [3, 'x', Application('max', Application('{}', ['x', 4]))])
assert str(e) == '{3, x, max {x, 4}}'
assert str(maximum(e)) == 'max {x, 4}'

e = Application('{}', [4, 3])
assert str(e) == '{4, 3}'
assert str(maximum(e)) == '4'

try:
    print(maximum(Application('{}', [])))
except Exception as m:
    assert str(m) == 'max of empty collection'

```
</div>

</div>



Function `universal(e)` constructs an object representing `all e` for set `e` of booleans. Following simplifications are performed if the argument is an enumerated set:

              all {}  →  true
          all {true}  →  true
      all {false, …}  →  false
    all {true, e, …}  →  any {e, …}



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def universal(e: Expression) -> Expression:
    if isinstance(e, Application) and e.fn == '{}':
        sa = [ei for ei in e.arg if ei is not True]
        if sa == []:
            return True
        elif False in sa:
            return False
        else:
            return Application('all', Application('{}', sa))
    else:
        return Application('all', e)


assert str(universal(Application('{}', []))) == 'True'
assert str(universal(Application('{}', [True]))) == 'True'
assert str(universal(Application('{}', [False]))) == 'False'
assert str(universal(Application('{}', [Application('>', ['x', 3])]))) == 'all {x > 3}'
assert str(universal(Application('∪', ['x', 'y']))) == 'all (x ∪ y)'


#     elif isinstance(e, Quantification): # set comprehension
#        assert e.quantifier == 'set', "argument of 'all' must be set"
#        if all(not substitution(e.cond, e.var, i) or substitution(e.body, e.var, i) \
#               for i in range(e.range[1], e.range[2] + 1)): return True
#        else: return Application('all', [e]) # not all values of the body are true

```
</div>

</div>



Function `existential(e)` constructs an `Application` representing `any e` for boolean set `e`. Following simplifications are performed if the argument is an enumerated set:

               any {}  →  false
          any {false}  →  false
        any {true, …}  →  true
    any {false, e, …}  →  any {e, …}



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def existential(e: Expression) -> Expression:
    if isinstance(e, Application) and e.fn == '{}':
        sa = [ei for ei in e.arg if ei is not False]
        if sa == []:
            return False
        elif True in sa:
            return True
        else:
            return Application('any', Application('{}', sa))
    else:
        return Application('any', e)


assert str(existential(Application('{}', [True]))) == 'True'
assert str(existential(Application('{}', [False]))) == 'False'
assert str(existential(Application('{}', [Application('>', ['x', 3])]))) == 'any {x > 3}'
assert str(existential(Application('∪', ['x', 'y']))) == 'any (x ∪ y)'

```
</div>

</div>



Function `some(e)` constructs an object representing `some e` for set `e`. Following simplification is performed if the argument is an enumerated set:

    some {e₁, e₂, …}  →  eᵢ    for some i



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
from random import choice


# TODO move import to beginning, document dependency
# TODO choice in the compiler causes non-deterministic output

def some(e: Expression) -> Expression:
    if isinstance(e, Application) and e.fn == '{}':
        return choice(e.arg)
    else:
        return Application('some', e)


assert str(some(Application('{}', [1, 2]))) in ('1', '2')
assert str(some(Application('∪', ['x', 'y']))) == 'some (x ∪ y)'

```
</div>

</div>



Function `cardinality(e)` constructs an object representing `# e` for set `e`. Following simplfication is performed if the argument is an enumerated set:

    #{e₁, e₂, …}  →  c    where c = #{e₁, e₂, …}



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def cardinality(e: Expression) -> Expression:
    if isinstance(e, Application) and e.fn == '{}':
        return len(e.arg)
    else:
        return Application('#', e)  # other set expression


assert str(cardinality(Application('{}', [3, 5]))) == '2'
assert str(cardinality(Application('∪', ['x', 'y']))) == '# (x ∪ y)'

```
</div>

</div>



Function `statetest(s)` constructs an object representing `in s` for state `s`.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
# TODO add simplifications

def statetest(s: Expression) -> Expression:
    return Application('in', s)


assert str(statetest('S')) == 'in S'

```
</div>

</div>



Function `power(e, n)` constructs an object representing `eⁿ`, where `n` must be a string with one of the superscript digits `⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹`:



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
SUP = {'⁰': 0, '¹': 1, '²': 2, '³': 3, '⁴': 4, '⁵': 5, '⁶': 6, '⁷': 7, '⁸': 8, '⁹': 9}


def power(e: Expression, n: Expression) -> Expression:
    if isinstance(e, (int, Fraction)):
        return e ** SUP[n]
    elif n == '⁰':
        return 1
    elif n == '¹':
        return e
    else:
        return Application(n, e)


assert power(3, '²') == 9
assert power(Fraction(1, 2), '¹') == Fraction(1, 2)
assert power('x', '⁰') == 1
assert power('x', '¹') == 'x'

```
</div>

</div>



Function `addition(e₁, e₂, …)` constructs an object representing `e₁ + e₂ + …` for integer and fractional numbers `eᵢ`. Following simplifications are performed:

    e + (f + …)   →   e + f + …
    (e + …) + g   →   e + … + g
          e + c   →   c + e        for constant c if e is not a constant
          c + d   →   e            where e is c + d for constants c, d
          0 + e   →   e



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def addition(*el: Expression) -> Expression:
    sc, sa = 0, []  # sum of constants, simplified argument
    for e in iterate_associative_op('+', *el):
        if isinstance(e, (int, Fraction)):
            sc += e
        else:
            sa.append(e)

    return sc if len(sa) == 0 else \
        sa[0] if len(sa) == 1 and sc == 0 else \
            Application('+', sa) if sc == 0 else \
                Application('+', [sc] + sa)


assert str(addition(3, 2)) == '5'
assert str(addition(3, 'x')) == '(3 + x)'
assert str(addition('x', 0)) == 'x'
assert str(addition('x', 'y')) == '(x + y)'
assert str(addition(3, 'x', 2, 'y', 4)) == '(9 + x + y)'
assert str(addition(addition('e', 'f', 2), addition('g', 3, 'h'))) == '(5 + e + f + g + h)'

```
</div>

</div>



Function `subtraction(e, f)` constructs an object representing `e - f` for integer and fractional numbers `e`, `f`. Following simplifications are performed:

    e - (- f)   →   e + f
        e - 0   →   e
        0 - e   →   - e



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def subtraction(e: Expression, f: Expression) -> Expression:
    if isinstance(e, (int, Fraction)) and isinstance(f, (int, Fraction)):
        return e - f
    elif f == 0:
        return e
    elif e == 0:
        return negative(f)
    elif isinstance(f, Application) and f.fn == '⊖':
        return addition(e, f.arg)
    else:
        return Application('-', [e, f])


assert str(subtraction(3, 6)) == '-3'
assert str(subtraction('x', negative('y'))) == '(x + y)'
assert str(subtraction('x', 0)) == 'x'
assert str(subtraction(0, 'x')) == '- x'

```
</div>

</div>



Function `multiplication(e₁, e₂, …)` constructs an object representing `e₁ × e₂ × …` for integer and fractional numbers `eᵢ`. Following simplifications are performed:

    e × (f × …)   →   e × f × …
    (e × …) × g   →   e × … × g
          e × c   →   c × e        for constant c if e is not a constant
          c × d   →   e            where e is c + d for constants c, d
          0 × e   →   0
          1 × e   →   e



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def multiplication(*el: Expression) -> Expression:
    pc, sa = 1, []  # product of constants, simplified argument
    for e in iterate_associative_op('×', *el):
        if e == 0:
            return 0
        elif isinstance(e, (int, Fraction)):
            pc *= e
        else:
            sa.append(e)
    return pc if len(sa) == 0 else \
        sa[0] if len(sa) == 1 and pc == 1 else \
            Application('×', sa) if pc == 1 else \
                Application('×', [pc] + sa)


assert str(multiplication(3, 2)) == '6'
assert str(multiplication(3, 'x')) == '(3 × x)'
assert str(multiplication('x', 1)) == 'x'
assert str(multiplication('x', 'y')) == '(x × y)'
assert str(multiplication(3, 'x', 2, 'y', 4)) == '(24 × x × y)'
assert str(multiplication(multiplication('e', 'f', 2), multiplication('g', 3, 'h'))) == '(6 × e × f × g × h)'

```
</div>

</div>



Function `fractionaldivision(e, f)` constructs an object representing `e / f` for integer and fractional numbers `e`, `f`. Following simplifications are performed:

    0 / e   →   0
    e / 1   →   e



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def fractionaldivision(e: Expression, f: Expression) -> Expression:
    if isinstance(e, (int, Fraction)) and isinstance(f, (int, Fraction)):
        return Fraction(e) / f
    elif e == 0:
        return 0
    elif f == 1:
        return e
    else:
        return Application('/', [e, f])


assert str(fractionaldivision(6, 5)) == '6/5'
assert str(fractionaldivision('x', 'y')) == '(x / y)'
assert str(fractionaldivision(0, 'x')) == '0'
assert str(fractionaldivision('x', 1)) == 'x'

```
</div>

</div>



Function `integerdivision(e, f)` constructs an object representing `e div f` for integers `e`, `f`. Following simplification is performed:

    0 div e   →   0
    e div 1   →   e



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def integerdivision(e: Expression, f: Expression) -> Expression:
    if isinstance(e, int) and isinstance(f, int):
        return e // f
    elif e == 0:
        return 0
    elif f == 1:
        return e
    else:
        return Application('div', [e, f])


assert str(integerdivision(6, 5)) == '1'
assert str(integerdivision('x', 'y')) == '(x div y)'
assert str(integerdivision(0, 'x')) == '0'
assert str(integerdivision('x', 1)) == 'x'

```
</div>

</div>



Function `integermodulo(e, f)` constructs an object representing `e mod f` for integers `e`, `f`. Following simplifications are performed:

    0 mod e   →   0
    e mod 1   →   0



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def integermodulo(e: Expression, f: Expression) -> Expression:
    if isinstance(e, int) and isinstance(f, int):
        return e % f
    elif e == 0 or f == 1:
        return 0
    else:
        return Application('mod', [e, f])


assert str(integermodulo(6, 5)) == '1'
assert str(integermodulo('x', 'y')) == '(x mod y)'
assert str(integermodulo(0, 'x')) == '0'
assert str(integermodulo('x', 1)) == '0'

```
</div>

</div>



Function `conjunction(e₁, e₂, …)` constructs an object representing `e₁ ∧ e₂ ∧ …` for booleans `eᵢ`. Following simplifications are performed:

    e ∧ (f ∧ … )   →   e ∧ f ∧ …
    (e ∧ … ) ∧ f   →   e ∧ … ∧ f
        e ∧ true   →   e
        true ∧ e   →   e
       e ∧ false   →   false
       false ∧ e   →   false
       e ∧ … ∧ f   →   e ∧ …    if e is equal to f

The first two rules state that nested conjunctions are flattened; the rule is not applied recursively. In the last rule, two expressions in a conjunction are compared for equality using `==`.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def conjunction(*el: Expression) -> Expression:
    sa = []  # simplified argument
    for e in iterate_associative_op('∧', *el):
        if e is False:
            return False
        elif e is not True and e not in sa:
            sa.append(e)
    return True if len(sa) == 0 else \
        sa[0] if len(sa) == 1 else \
            Application('∧', sa)


assert str(conjunction(True, True)) == 'True'
assert str(conjunction(True, 'e', True, 'f', 'e', True)) == '(e ∧ f)'
assert str(conjunction('e', False)) == 'False'
assert str(conjunction(conjunction('e', 'f', 'g'), conjunction('e', 'h'))) == '(e ∧ f ∧ g ∧ h)'

```
</div>

</div>



Function `disjunction(e₁, e₂, …)` constructs an object representing `e₁ ∧ e₂ ∧ …` for booleans `eᵢ`. Following simplifications are performed:

    e ∨ (f ∨ … )   →   e ∨ f ∨ …
    (e ∨ … ) ∨ f   →   e ∨ … ∨ f
        e ∨ true   →   true
        true ∨ e   →   true
       e ∨ false   →   e
       false ∨ e   →   e
       e ∨ … ∨ f   →   e ∨ …    if e is equal to f

The first two rules state that nested disjunctions are flattened; the rule is not applied recursively. In the last rule, two expressions in a conjunction are compared for equality using `==`.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def disjunction(*el: Expression) -> Expression:
    sa = []  # simplified argument
    for e in iterate_associative_op('∨', *el):
        if e is True:
            return True
        elif e is not False and e not in sa:
            sa.append(e)
    return False if len(sa) == 0 else \
        sa[0] if len(sa) == 1 else \
            Application('∨', sa)


assert str(disjunction(False, 'e', False, 'f', 'e', False)) == '(e ∨ f)'
assert str(disjunction('e', True)) == 'True'
assert str(disjunction(disjunction('e', 'f', 'g'), disjunction('e', 'h'))) == '(e ∨ f ∨ g ∨ h)'

```
</div>

</div>



Function `implication(e, f)` constructs an object representing `e ⇒ f` for booleans `e`, `f`. Following simplifications are performed:

    e ⇒ f      →  true    if e is equal to f
    e ⇒ true   →  true
    e ⇒ false  →  ¬e
    true ⇒ e   →  e
    false ⇒ e  →  true

TODO simplify `e ⇒ f` to `¬e ∨ f`?



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def implication(e: Expression, f: Expression) -> Expression:
    return True if e == f else \
           True if f is True else \
           negation(e) if f is False else \
           f if e is True else \
           True if e is False else \
           Application('⇒', [e, f])


assert str(implication('e', 'e')) == 'True'
assert str(implication('e', True)) == 'True'
assert str(implication('e', False)) == '¬ e'
assert str(implication(True, 'e')) == 'e'
assert str(implication(False, 'e')) == 'True'
assert str(implication('e', 'f')) == '(e ⇒ f)'

```
</div>

</div>



Function `consequence(e, f)` constructs an object representing `e ⇐ f` for booleans `e`, `f`. Following simplification is performed:

    e ⇐ f  →  e ⇒ f

TODO Eliminate `⇐` when parsing?



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def consequence(e: Expression, f: Expression) -> Expression:
    return implication(f, e)

```
</div>

</div>



Function `equivalence(e, f)` constructs an object representing `e ≡ f` for booleans `e`, `f`. Following simplification is performed:

    e ≡ f  →  e = f

TODO Eliminate `≡` when parsing?



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def equivalence(e: Expression, f: Expression) -> Expression:
    return equality(f, e)

```
</div>

</div>



Function `disequivalence(e, f)` constructs an object representing `e ≢ f` for booleans `e`, `f`. Following simplification is performed:

    e ≢ f  →  e ≠ f

TODO Eliminate `≢` when parsing?



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def disequivalence(e: Expression, f: Expression) -> Expression:
    return disequality(f, e)

```
</div>

</div>



Function `equality(e, f)` constructs an object representing `e = f`. Following simplifications are performed:

        e = f  →  true    if e is equal to f
        c = d  →  false   if c is not equal to d for constants c, d
     e = true  →  e
     true = e  →  e
    e = false  →  ¬e
    false = e  →  ¬e



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def equality(e: Expression, f: Expression) -> Expression:
    return True if e == f else \
           False if isinstance(e, (int, bool, Fraction)) and isinstance(f, (int, bool, Fraction)) and e != f else \
           e if f is True else \
           f if e is True else \
           negation(e) if f is False else \
           negation(f) if e is False else \
           Application('=', [e, f])


assert str(equality(Application('+', ['x', 'y', 'z']), Application('+', ['y', 'z', 'x']))) == 'True'
assert str(equality(3, 3)) == 'True'
assert str(equality('e', True)) == 'e'
assert str(equality(True, 'e')) == 'e'
assert str(equality('e', False)) == '¬ e'
assert str(equality(False, 'e')) == '¬ e'
assert str(equality('e', 'f')) == '(e = f)'

```
</div>

</div>



Function `disequality(e, f)` constructs an object representing `e ≠ f`. Following simplification is performed:

    e ≠ f  →  ¬(e = f)

While this rule is not a simplification in itself, it does allow simplifications of negation (like eliminating double negation) and equality to be carried out.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def disequality(e: Expression, f: Expression) -> Expression:
    return negation(equality(e, f))


assert str(disequality('e', False)) == 'e'

```
</div>

</div>



Function `lessequal(e, f)` constructs an object representing `e ≤ f` for integer and fractional numbers `e`, `f`. Following simplifications are performed:

    e ≤ f  →  true    if e is equal to f
    c ≤ d  →  e       if e is equal to c ≤ d for constants c, d



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def lessequal(e: Expression, f: Expression) -> Expression:
    return True if e == f else \
           e <= f if isinstance(e, (int, Fraction)) and isinstance(f, (int, Fraction)) else \
           Application('≤', [e, f])


assert str(lessequal(7, 3)) == 'False'

```
</div>

</div>



Function `greaterequal(e, f)` constructs an object representing `e ≥ f` for integer and fractional numbers `e`, `f`. Following simplification are performed:

    e ≥ f  →  true    if e is equal to f
    c ≥ d  →  e       where e is equal to c ≥ d for constants c, d



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def greaterequal(e: Expression, f: Expression) -> Expression:
    return True if e == f else \
           e >= f if isinstance(e, (int, Fraction)) and isinstance(f, (int, Fraction)) else \
           Application('≥', [e, f])


assert str(greaterequal(7, 3)) == 'True'

```
</div>

</div>



Function `less(e, f)` constructs an object representing `e < f` for integer and fractional numbers `e`, `f`. Following simplifications are performed:

    e < f  →  false    if e is equal to f
    c < d  →  e        where e is equal to c < d for constants c, d



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def less(e: Expression, f: Expression) -> Expression:
    return False if e == f else \
           e > f if isinstance(e, (int, Fraction)) and isinstance(f, (int, Fraction)) else \
           Application('<', [e, f])


assert str(less(3, 3)) == 'False'

```
</div>

</div>



Function `greater(e, f)` constructs an object representing `e > f` for integer and fractional numbers `e`, `f`. Following simplifications are performed:

    e > f  →  false    if e is equal to f
    c > d  →  e        if e is equal to c > d for constants c, d



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def greater(e: Expression, f: Expression) -> Expression:
    return False if e == f else \
           e > f if isinstance(e, (int, Fraction)) and isinstance(f, (int, Fraction)) else \
           Application('>', [e, f])


assert str(greater('e', 'f')) == '(e > f)'

```
</div>

</div>



Function `member(e, f)` constructs an object representing `e ∈ f` for set `f` of elements of subrange type. Following simplifications are performed if `f` is an enumerated set:

    e ∈ {e₁, e₂, …}  →  true    if e is equal to some eᵢ



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def member(e: Expression, f: Expression) -> Expression:
    if isinstance(f, Application) and f.fn == '{}':  # set enumeration
        if any(e == fi for fi in f.arg):
            return True
        elif len(f.arg) == 0:
            return False
        elif isinstance(e, int) and all(isinstance(fi, int) for fi in f.arg):
            return e in f.arg
        else:
            return Application('∈', [e, f])
    else:
        return Application('∈', [e, f])  # other set expression


e = Application('+', ['x', 'y'])
assert str(member(e, Application('{}', ['x', e, 'y']))) == 'True'
assert str(member(e, Application('{}', []))) == 'False'
assert str(member(3, Application('{}', [1, 7]))) == 'False'
assert str(member(e, Application('{}', ['x', 'y']))) == '((x + y) ∈ {x, y})'

```
</div>

</div>



Function `notmember(e, f)` constructs an object representing `e ∉ f` for set `f` of elements of subrange type. Following simplification is performed:

    e ∉ f  →  ¬(e ∈ f)



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def notmember(e: Expression, f: Expression) -> Expression:
    return negation(member(e, f))


assert str(notmember('x', Application('{}', ['x', 'y']))) == 'False'

```
</div>

</div>



Function `subsetequal(e, f)` constructs an object representing `e ⊆ f` for sets `e`, `f` with elements of subrange type. Following simplifications are performed:

    {e₁, e₂, …} ⊆ {f₁, f₂, …}  →  true    if every eᵢ is equal to some fⱼ
    {c₁, c₂, …} ⊆ {d₁, d₂, …}  →  e       where e is {c₁, c₂, …} ⊆ {d₁, d₂, …} for constants cᵢ, dⱼ
                  {e, …} ⊆ {}  →  false
                       {} ⊆ e  →  true



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def subsetequal(e: Expression, f: Expression) -> Expression:
    if isinstance(e, Application) and e.fn == '{}':
        if isinstance(f, Application) and f.fn == '{}':  # set enumeration
            if all(any(ei == fi for fi in f.arg) for ei in e.arg):
                return True
            elif all(isinstance(ei, int) for ei in e.arg) and all(isinstance(fi, int) for fi in f.arg):
                return False
            elif len(f.arg) == 0:
                return False
            else:
                return Application('⊆', [e, f])
        elif len(e.arg) == 0:
            return True
        else:
            return Application('⊆', [e, f])
    else:
        return Application('⊆', [e, f])  # other set expression


e = Application('+', ['x', 'y'])
assert str(subsetequal(Application('{}', [e, 'x']), Application('{}', ['x', e, 'y']))) == 'True'
assert str(subsetequal(Application('{}', [3]), Application('{}', [5]))) == 'False'
assert str(subsetequal(Application('{}', ['e']), Application('{}', []))) == 'False'
assert str(subsetequal(Application('{}', [e]), Application('{}', ['y']))) == '({x + y} ⊆ {y})'
assert str(subsetequal(Application('{}', []), 'e')) == 'True'

```
</div>

</div>



Function `supersetequal(e, f)` constructs an object representing `e ⊆ f` for sets `e`, `f` with elements of subrange type. Following simplification is performed:

    e ⊇ f  →  f ⊆ e

TODO Treat ⊇ properly rather than by translation to ⊆?



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def supersetequal(e: Expression, f: Expression) -> Expression:
    return subsetequal(f, e)


assert str(supersetequal(Application('{}', ['x', 'y']), Application('{}', ['y']))) == 'True'
assert str(supersetequal(Application('{}', []), 'e')) == '(e ⊆ {})'

```
</div>

</div>



Function `subset(e, f)` constructs an object representing `e ⊂ f` for sets `e`, `d` with elements of subrange type. Following simplifications are performed:

    {c₁, c₂, …} ⊂ {d₁, d₂, …}  →  e        where e is {c₁, c₂, …} ⊂ {d₁, d₂, …} for constants cᵢ, dⱼ
                  {} ⊂ {e, …}  →  true
                       e ⊂ {}  →  false



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def subset(e: Expression, f: Expression) -> Expression:
    if isinstance(f, Application) and f.fn == '{}':
        if isinstance(e, Application) and e.fn == '{}' and \
                all(isinstance(ei, int) for ei in e.arg) and all(isinstance(fi, int) for fi in f.arg):
            return set(e.arg).issubset(set(f.arg)) and set(e.arg) != set(f.arg)
        elif len(f.arg) == 0:
            return False
        elif len(e.arg) == 0:
            return True
        else:
            return Application('⊂', [e, f])
    else:
        return Application('⊂', [e, f])


e = Application('+', ['x', 'y'])
assert str(subset(Application('{}', [1]), Application('{}', [1, 2]))) == 'True'
assert str(subset(Application('{}', [3]), Application('{}', [5]))) == 'False'
assert str(subset(Application('{}', []), Application('{}', ['x']))) == 'True'
assert str(subset('e', Application('{}', []))) == 'False'
assert str(subset(Application('{}', [e]), Application('{}', ['y']))) == '({x + y} ⊂ {y})'

```
</div>

</div>



Function `superset(e, f)` constructs an object representing `e ⊃ f` for sets `e`, `f` with elements of subrange type. Following simplification is performed:

    e ⊃ f  →  f ⊂ e

TODO Treat ⊃ properly rather than by translation to ⊂?



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def superset(e: Expression, f: Expression) -> Expression:
    return subset(f, e)


assert str(superset(Application('{}', ['x', 'y']), Application('{}', ['y']))) == '({y} ⊂ {x, y})'
assert str(superset(Application('{}', []), 'e')) == 'False'

```
</div>

</div>



Function `intersection(e₁, e₂, …)` constructs an object representing `e₁ ∩ e₂ ∩ …` for booleans `eᵢ`. Following simplifications are performed:

       e ∩ (f ∩ … )   →   e ∩ f ∩ …
       (e ∩ … ) ∩ f   →   e ∩ … ∩ f
    e ∩ {f₁, f₂, …}   →   {f₁, f₂, …} ∩ e    if e is not a set comprehension
             {} ∩ e   →   {}
    {e, …} ∩ {f, …}   →   g                  where g is {e, …} ∩ {f, …}
          e ∩ … ∩ f   →   e ∩ …              if e is equal to f

The first two rules state that nested conjunctions are flattened; the rule is not applied recursively. In the last rule, two expressions in a conjunction are compared for equality using `==`.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def intersection(*el: Expression) -> Expression:
    ie, sa = None, []  # intersection of set enumerations, simplified argument
    for e in iterate_associative_op('∩', *el):
        if isinstance(e, Application) and e.fn == '{}':
            if ie is not None:
                ie = [ei for ei in ie if ei in e.arg]
            else:
                ie = e.arg
        elif e not in sa:
            sa.append(e)
    return Application('{}', ie) if len(sa) == 0 else \
        Application('{}', []) if ie == [] else \
            sa[0] if len(sa) == 1 and ie is None else \
                Application('∩', sa) if ie is None else \
                    Application('∩', [Application('{}', ie)] + sa)


assert str(intersection(Application('{}', [1, 3]), Application('{}', [1, 2]))) == '{1}'
assert str(intersection('e', Application('{}', []))) == '{}'
assert str(intersection('e', 'e')) == 'e'
assert str(intersection(intersection('e', 'f'), intersection('f', 'g'))) == '(e ∩ f ∩ g)'
assert str(intersection(Application('{}', [1, 2]), 'e', Application('{}', [2, 3]), 'f',
                        Application('{}', [1, 2, 3]))) == '({2} ∩ e ∩ f)'

```
</div>

</div>



Function `union(e₁, e₂, …)` constructs an object representing `e₁ ∪ e₂ ∪ …` for booleans `eᵢ`. Following simplifications are performed:

       e ∪ (f ∪ … )   →   e ∪ f ∪ …
       (e ∪ … ) ∪ f   →   e ∪ … ∪ f
    e ∪ {f₁, f₂, …}   →   {f₁, f₂, …} ∪ e    if e is not a set comprehension
             {} ∪ e   →   e
    {e, …} ∪ {f, …}   →   g                  where g is {e, …} ∪ {f, …}
          e ∪ … ∪ f   →   e ∪ …              if e is equal to f

The first two rules state that nested conjunctions are flattened; the rule is not applied recursively. In the last rule, two expressions in a conjunction are compared for equality using `==`.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def union(*el: Expression) -> Expression:
    ue, sa = [], []  # union of set enumerations, simplified argument
    for e in iterate_associative_op('∪', *el):
        if isinstance(e, Application) and e.fn == '{}':
            ue.extend(ei for ei in e.arg if ei not in ue)
        elif e not in sa:
            sa.append(e)
    return Application('{}', ue) if len(sa) == 0 else \
        sa[0] if len(sa) == 1 and ue == [] else \
            Application('∪', sa) if ue == [] else \
                Application('∪', [Application('{}', ue)] + sa)


assert str(union(Application('{}', [1]), Application('{}', [2]))) == '{1, 2}'
assert str(union('e', Application('{}', []), 'e')) == 'e'
assert str(union(union('e', 'f'), union('f', 'g'))) == '(e ∪ f ∪ g)'
assert str(union(Application('{}', [1, 2]), 'e', Application('{}', [2, 3]), 'f',
                 Application('{}', [1, 2, 3]))) == '({1, 2, 3} ∪ e ∪ f)'

```
</div>

</div>



Function `difference(e, f)` constructs an object representing `e \ f` for sets `e`, `f`. Following simplifications are performed:

                       e \ {}   →   e
                       {} \ e   →   {}
                        e \ e   →   {}
    {c₁, c₂, …} \ {d₁, d₂, …}   →   e    where e is {c₁, c₂, …} \ {d₁, d₂, …} for constants cᵢ, dⱼ



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def difference(e: Expression, f: Expression) -> Expression:
    if e == f:
        return Application('{}', [])
    elif isinstance(e, Application) and e.fn == '{}' and e.arg == []:
        return Application('{}', [])
    elif isinstance(f, Application) and f.fn == '{}' and f.arg == []:
        return e
    elif isinstance(e, Application) and all(isinstance(ei, int) for ei in e.arg) and \
            isinstance(f, Application) and all(isinstance(fj, int) for fj in f.arg):
        return Application('{}', [ei for ei in e.arg if all(ei != fj for fj in f.arg)])
    else:
        return Application('\\', [e, f])


assert str(difference('e', Application('{}', []))) == 'e'
assert str(difference(Application('{}', []), 'e')) == '{}'
assert str(difference('e', 'e')) == '{}'
assert str(difference(Application('{}', [1, 2]), Application('{}', [2, 3]))) == '{1}'

```
</div>

</div>



Function `conditional(b, e, f)` constructs an object representing `b ? e : f` for boolean `e`. Following simplifications are performed:

     true ? e : f   →   e
    false ? e : f   →   f



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def conditional(b: Expression, e: Expression, f: Expression) -> Expression:
    if b is True:
        return e
    elif b is False:
        return f
    else:
        return Application('?', [b, e, f])


assert str(conditional(True, 'e', 'f')) == 'e'
assert str(conditional(False, 'e', 'f')) == 'f'
assert str(conditional('b', 'e', 'f')) == '(b ? e : f)'

```
</div>

</div>



Function `setenumeration(e₁, e₂, …)` constructs an object representing `{e₁, e₂, …}`. Following simplification is performed:

    {e, …, f}   →   {e, …}              if e is equal to f



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def setenumeration(*el: Expression) -> Expression:
    sa = []  # simplified argument
    for e in el:
        if e not in sa: sa.append(e)
    return Application('{}', sa)


assert str(setenumeration(1, 2, 1, 2, 2)) == '{1, 2}'
assert str(setenumeration()) == '{}'

```
</div>

</div>



Function `inverval(e, f)` constructs an object representing `e ‥ f`.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def inverval(e: Expression, f: Expression) -> Expression:
    return Application('‥', [e, f])


assert str(inverval('x', 'y')) == '(x ‥ y)'


# TODO membership, containment, union, intersection, difference of intervals, enumerations and intervals

```
</div>

</div>



Function `setcomprehension(e, i, r, b)` constructs an expression representing `{e ∣ i ∈ r, b}` for expressions `e`, `r`, `b` and variable `i`.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def setcomprehension(i: str, r: Type, b: Expression, e: Expression) -> Expression:
    return Application('set', Abstraction(i, r, b, e))


assert str(setcomprehension('i', Type('‥', 2, 7), True, Application('+', ['i', 3]), )) == \
       'set (i ∈ 2 ‥ 7 • i + 3)'  # {i + 3 | i ∈ 2 ‥ 7}
assert str(setcomprehension('i', Type('‥', 2, 7), Application('<', ['i', 'j']), 'i')) == \
       'set (i ∈ 2 ‥ 7, i < j • i)'  # {i | i ∈ 2 ‥ 7, i < j}


# TODO union etc of set comprehensions

```
</div>

</div>



Function `abstraction(i, r, b, e)` constructs an expression representing `i ∈ r, b → e` for variable `x`, type `r`, and expressions `b`, `e`.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def abstraction(var: Text, range: Optional[Type], cond: Optional['Expression'], body: 'Expression'):
    return Abstraction(var, range, cond, body)


assert str(Application('∑', abstraction('i', Type('‥', 2, 7), True, Application('+', ['i', 3])))) == \
       '∑ (i ∈ 2 ‥ 7 • i + 3)'


# TODO improve pretty-printing of set comprehension and quantifications

```
</div>

</div>



Function `simplification(e)` decomposes expression `e` and uses all above simplifications to reconstruct an equivalent expression. It is meant to be used after a substitution within an expression that may allow further simplifications.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def simplification(e: Expression) -> Expression:
    if isinstance(e, (int, bool, Fraction, str)):
        return e
    elif isinstance(e, list):
        return [simplification(ei) for ei in e]
    elif isinstance(e, Application):
        return \
            negative(simplification(e.arg)) if e.fn == '⊖' else \
            negation(simplification(e.arg)) if e.fn == '¬' else \
            summation(simplification(e.arg)) if e.fn == '∑' else \
            product(simplification(e.arg)) if e.fn == '∏' else \
            minimum(simplification(e.arg)) if e.fn == 'min' else \
            maximum(simplification(e.arg)) if e.fn == 'max' else \
            universal(simplification(e.arg)) if e.fn == 'all' else \
            existential(simplification(e.arg)) if e.fn == 'any' else \
            some(simplification(e.arg)) if e.fn == 'some' else \
            cardinality(simplification(e.arg)) if e.fn == '#' else \
            statetest(simplification(e.arg)) if e.fn == 'in' else \
            power(simplification(e.arg), e.fn) if e.fn in '⁰¹²³⁴⁵⁶⁷⁸⁹' else \
            addition(simplification(e.arg)) if e.fn == '+' else \
            subtraction(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '-' else \
            multiplication(simplification(e.arg)) if e.fn == '×' else \
            fractionaldivision(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '/' else \
            integerdivision(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == 'div' else \
            integermodulo(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == 'mod' else \
            conjunction(simplification(e.arg)) if e.fn == '∧' else \
            disjunction(simplification(e.arg)) if e.fn == '∨' else \
            implication(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '⇒' else \
            consequence(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '⇐' else \
            equivalence(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '≡' else \
            disequivalence(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '≢' else \
            equality(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '=' else \
            disequality(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '≠' else \
            lessequal(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '≤' else \
            greaterequal(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '≥' else \
            less(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '<' else \
            greater(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '>' else \
            member(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '∈' else \
            notmember(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '∉' else \
            subsetequal(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '⊆' else \
            supersetequal(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '⊇' else \
            subset(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '⊂' else \
            superset(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '⊃' else \
            intersection(simplification(e.arg)) if e.fn == '∩' else \
            union(simplification(e.arg)) if e.fn == '∪' else \
            difference(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '\\' else \
            conditional(simplification(e.arg[0]), simplification(e.arg[1]), simplification(e.arg[2])) if e.fn == '?' else \
            setenumeration(simplification(e.arg)) if e.fn == '{}' else \
            interval(simplification(e.arg[0]), simplification(e.arg[1])) if e.fn == '‥' else \
            simplification(e) if e.fn == 'set' else \
            Application(',', simplification(e.arg)) if e.fn == ',' else \
            None
    elif isinstance(e, Abstraction):
        return Abstraction(e.var, simplification(e.range), simplification(e.cond), simplification(e.body))
    elif isinstance(e, Type):
        return Type(e.kind, *simplification(e.args))
    else:
        assert False, "invalid kind of expression"

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
assert simplification(Application('div', [3, 2])) == 1
assert simplification(Application('=', ['x', 'x'])) is True

```
</div>

</div>



## Statements



Chart events are translated to an intermediate representation, _probabilistic guarded commands_, an extension of chart statements with the empty statement, guarded composition, and probabilistic composition:

| Statement                 | Notation                    | Effect
|:--------------------------|:----------------------------|:-------------
| Empty Statement           | `skip`                      | do nothing
| Guarded Composition       | `b₁ → s₁ ⫿ b₂ → s₂ ⫿ …`      | choose any `sᵢ` for which `bᵢ` is true and block if all `bᵢ` are false
|                           | `b₁ → s₁ ⫿ b₂ → s₂ ⫿ … ⫽ s₀` | choose any `sᵢ` for which `bᵢ` is true and `s₀` if all `bᵢ` are false
| Probabilistic Composition | `p₁ : s₁ ⊕ p₂ → s₂ ⊕ …`    | choose `sᵢ` with probability `pᵢ`

In isolation, the _guarded command_ `b → s` executes `s` if `b` holds and _blocks_ otherwise; the _nondeterministic choice_ `s ⫿ t` selects either `s` or `t`, whichever does not block; the _prioritizing composition_ `s ⫽ t` executes `s` if `s` does not block and `t` otherwise. Here, these are only used in above two forms, with an additional constraint: in `b₁ → s₁ ⫿ b₂ → s₂ ⫿ …`, one of the `bᵢ` must be true, hence the composition does not block. As `b₁ → s₁ ⫿ b₂ → s₂ ⫿ … ⫽ s₀` does not block, assuming that `s₀` does not block, it follows by induction over the structure of statements that no statement blocks. In the probabilistic composition, the probabilities have to sum up to `1`.

**Representation.** A broadcast statement is represented by a `str` object for the event. Statement `skip` is represented by the sole object `skip` of class `Skip`. Assignments, parallel compositions, conditional statements, guarded compositions,  and probabilistic compositions are represented by objects of their respective classes.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def eq_unordered(c1: Collection, c2: Collection) -> bool:
    if len(c1) != len(c2): return False

    c2 = list(c2)  # mutable copy
    for c in c1:
        try:
            c2.remove(c)
        except ValueError:
            return False

    return len(c2) == 0


class Skip(NamedTuple):
    def __str__(self):
        return 'skip'


# TODO: should var be Designator or list of str? Should probably be text and expr
class Assignment(NamedTuple):
    var: Expression
    expr: Expression

    def __str__(self):
        return str(self.var) + ' ≔ ' + str(self.expr)


class ParallelComp(NamedTuple):
    elems: Collection['Statement']

    def __str__(self):
        return '(' + ' ∥ '.join([str(e) for e in self.elems]) + ')'

    def __eq__(self, other):
        return self is other \
               or (isinstance(other, ParallelComp) and eq_unordered(self.elems, other.elems))


class CondStat(NamedTuple):
    cond: Expression
    thn: 'Statement'
    els: Optional['Statement'] = None

    def __str__(self):
        return 'if ' + nstr(self.cond) + ' then ' + str(self.thn) + ' else ' + str(self.els) \
            if self.els is not None else 'if ' + nstr(self.cond) + ' then ' + str(self.thn)


class GuardedCompElem(NamedTuple):
    guard: Expression
    body: 'Statement'


class GuardedComp(NamedTuple):
    elems: Collection[GuardedCompElem]
    els: Optional['Statement'] = None

    def __str__(self):
        return '(' + ' ⫿ '.join([str(e.guard) + ' → ' + str(e.body) for e in self.elems]) + \
               (' ⫽ ' + str(self.els) if self.els is not None else '') + ')'

    def __eq__(self, other):
        return self is other \
               or (isinstance(other, GuardedComp) and eq_unordered(self.elems, other.elems) and self.els == other.els)


class ProbCompElem(NamedTuple):
    prob: Expression
    body: 'Statement'


class ProbComp(NamedTuple):
    elems: Collection[ProbCompElem]

    def __str__(self):
        return '(' + ' ⊕ '.join([str(e.prob) + ' : ' + str(e.body) for e in self.elems]) + ')'

    def __eq__(self, other):
        return self is other \
               or (isinstance(other, ProbComp) and eq_unordered(self.elems, other.elems))

# TODO GuardedComp and ProbComp not mentioned in verification timed paper
Broadcast = Text
Statement = Union[Skip, Broadcast, Assignment, ParallelComp, CondStat, GuardedComp, ProbComp]

skip = Skip()

```
</div>

</div>



Function `parallel(S1, ..., Sn)` constructs a `ParallelComp` object representing `S1 ∥ ... ∥ Sn`. Following simplifications are performed, where `S, T, U` are statements:

    S ∥ (T ∥ U)   ＝   S ∥ T ∥ U   ＝   (S ∥ T) ∥ U
          S ∥ skip   ＝   S   ＝   skip ∥ S

That is, nested parallel compositions are flattened (not recursively) and compositions with `skip` are left out.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def parallel(*sl: Statement) -> Statement:
    args = []
    for s in sl:
        if isinstance(s, ParallelComp):
            args.extend(s.elems)
        elif s == skip:
            pass
        else:
            args.append(s)
    return skip if len(args) == 0 else \
        args[0] if len(args) == 1 else \
            ParallelComp(args)


assert str(parallel(parallel('S', 'T'), parallel('U', 'V'))) == '(S ∥ T ∥ U ∥ V)'
assert str(parallel(skip, 'S', skip, 'T', skip)) == '(S ∥ T)'

```
</div>

</div>



Function `guarded((g1, S1), ..., (gn, Sn), els=S0)` takes pairs consisting of an expression, the guard, and a statement and optionally an `els` statement, and constructs a `GuardedComp` object representing `g1 → S1 ⫿ ... ⫿ gn → Sn ⫽ S0`. If there is no choice, `S0` is returned. If there is only a single choice with guard `true`, the associated statement is returned:

    true → S   ＝   S



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def guarded(*sl: Tuple[Expression, Statement], els: Optional[Statement] = None) -> Optional[Statement]:
    return els if len(sl) == 0 else \
        sl[0][1] if len(sl) == 1 and sl[0][0] is True else \
            GuardedComp([GuardedCompElem(*s) for s in sl], els)


assert str(guarded((True, 'S'))) == 'S'
assert str(guarded(('g', 'S'), ('h', 'T'))) == '(g → S ⫿ h → T)'
assert str(guarded(('g', 'S'), ('h', 'T'), els='U')) == '(g → S ⫿ h → T ⫽ U)'

```
</div>

</div>



Function `prob((p1, S1), ..., (pn, Sn))` takes pairs consisting of a fractional number, the probability, and a statement, and constructs a `ProbComp` object representing `p1 : S1 ⊕ ... ⊕ pn : Sn`. The probabilities must add up to 1, hence the list cannot be empty. If there is only one probabilistic alternative, which must have probability 1, the associated statement is returned:

    1 : S   ＝   S



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def prob(*pl: Tuple[Fraction, Statement]) -> Statement:
    return pl[0][1] if len(pl) == 1 else ProbComp([ProbCompElem(*p) for p in pl])


assert str(prob((Fraction(1), 'S'))) == 'S'
assert str(prob((Fraction(1, 3), 'S'), (Fraction(2, 3), 'T'))) == '(1/3 : S ⊕ 2/3 : T)'

```
</div>

</div>



## Scanning and Parsing Labels
See [parser.py](./parser.py)



## Generating the Intermediate Representation
See [intermediate.py](./intermediate.py)



## Converting State Graphs to Charts
See [serialization.py](./serialization.py)



## Accumulating Invariants
See [intermediate.py](./intermediate.py)



## Well-Formedness of Charts
See [checks.py](./checks.py)



## Well-Definedness of Transition Expressions
See [checks.py](./checks.py)



## Statement Correctness
See [checks.py](./checks.py)



## Chart Correctness
See [checks.py](./checks.py)



## Adding Costs



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
def additiveCosts(s: State) -> "additive costs for s and all ancestors; only meaningful if s is Basic":
    cost = {}
    while s:
        for c in cost.keys() | s.cost.keys():
            cost[c] = (cost[c] if c in cost else 0) + (s.cost[c] if c in s.cost else 0)
        s = s.parent
    return cost

```
</div>

</div>



## Type-checking the pState Core



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
!jupyter nbconvert --to script Core.ipynb

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
!ls

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
!mypy Core.py

```
</div>

</div>



## References



