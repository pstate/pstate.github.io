---
interact_link: content/documentation/pstate-core/serialization.ipynb
kernel_name: python3
has_widgets: false
title: 'Serialization'
prev_page:
  url: /documentation/pstate-core/parser
  title: 'Parser'
next_page:
  url: https://github.com/jupyter/jupyter-book
  title: 'GitHub repository'
comment: "***PROGRAMMATICALLY GENERATED, DO NOT EDIT. SEE ORIGINAL FILES IN /content***"
---


# Converting State Graphs to Charts



The JavaScript Object Notation, JSON, is a textual interface format for (nested) objects (records), arrays (lists), strings, and numbers. The pState Core receives _state graph_ with _nodes_ and _connections_ from the front end in JSON. From the state graph, first the state hierarchy is constructed. If there are no errors, the transitions of a chart are constructed.



VERSION USING CHILDREN FIELD

The state hierarchy is built by
- creating the Root state from the `root` node,
- repeatedly creating states for all the children of the nodes visited so far,
- classifying the created states as Basic, Xor, And,
- parsing all node labels and setting the corresponding fields of the states.

As expressions in state labels may contain state tests, these can only be checked after the state hierarchy is built, hence all state labels are parsed as the last step. For nodes of `xor` type, a Basic or Xor state is created, depending on whether the node has children. For `and` nodes, an And state is created. Following checks are performed on the nodes while building the state hierarchy:
- A state with id `root` must be defined among the nodes.
- All nodes in `children` fields must be defined.
- The relation among nodes given by the `children` field must not be cyclic.
- There cannot be orphans, i.e. nodes that are not descendants of `root`.
- The type of each node must be present and must be one `init`, `prob`, `cond`, `xor`, `and`.
- `init`, `prob`, `cond` nodes can be children only of `xor` nodes.
- Basic and And states must have Xor parents.

The last rule implies that Root must be an Xor state, if there are any children.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
# VERSION USING CHILDREN FIELD
# TODO buildStates uses the 'children' field of 'nodes', buildTransitions uses the 'parent' field;
# revise buildStates to use only parent? Would make finding orphans simpler.
from fractions import Fraction
from typing import NamedTuple, MutableSet, Mapping, Text, Sequence, MutableMapping, Set, List

from pstate.core.core import skip, State, Error, ChartMessages, ChartException, Conditional, Alternative, Transition
from pstate.core.parser import parseStateLabel, parseCondConnectionLabel, parseProbConnectionLabel, \
    parseFirstConnectionLabel
from pstate.server.chart import StateProxy, StateType, ChartProxy, ConnectionProxy
from pstate.server.json_proxy import AnyJson


class StatesManifest(NamedTuple):
    root: State
    Basic: MutableSet[State]
    Xor: MutableSet[State]
    And: MutableSet[State]
    directory: Mapping[Text, State]

def buildStates(nodes: Mapping[Text, StateProxy]) -> StatesManifest:
    # 1. create the root state from the `root` node

    if 'root' not in nodes: raise Error('No root node defined')  # can't continue
    root = State(id='root', parent=None)
    msgs = []

    # 2. repeatedly create states for all the children of the nodes visited so far;
    #    classify the created states as Basic, Xor, And

    Basic: MutableSet[State] = set()
    Xor: MutableSet[State] = set()
    And: MutableSet[State] = set()

    chartstate, pseudostate = {}, set()  # map id to State, set of id

    visit: MutableSet[State] = {root}  # set of states to visit
    while len(visit) > 0:
        state = visit.pop()  # pick an arbitrary state

        if state.id in chartstate:  # already visited
            raise Error('Child relation is cyclic', state.id)  # can't continue
        chartstate[state.id] = state

        node = nodes[state.id]  # node is the node corresponding to state
        if node.children is not None:
            for child_id in node.children or ():
                child_proxy = nodes.get(child_id)
                if child_proxy is None:
                    msgs.append(Error('Missing child definition', child_id))
                    continue

                child_type = child_proxy.type
                if child_type in (StateType.AND, StateType.XOR):
                    state.children.add(State(child_id, state))
                elif child_type in (StateType.INIT, StateType.PROB, StateType.CHOICE):
                    pseudostate.add(child_id)
                    if node.type not in (StateType.XOR, StateType.ROOT):
                        msgs.append(Error('Parent must be Xor state', child_id))
                else:
                    msgs.append(Error('State type must be one of "xor", "and", "init", "prob", "choice"', child_id))

            visit |= state.children

        if node.type == StateType.AND:
            if state.parent in Xor:
                And.add(state)
            else:
                msgs.append(Error('And state must have Xor parent', state.id))
        elif node.type == StateType.XOR:
            if len(state.children) == 0:  # node type is xor, no children
                if state.parent in Xor:
                    Basic.add(state)
                else:
                    msgs.append(Error('Basic state must have Xor parent', state.id))
            else:
                Xor.add(state)
        elif node.type == StateType.ROOT:
            # TODO is this the appropriate way to handle the root? How should any empty chart be parsed?
            Xor.add(state)

    # 3. parsing all state labels and setting the corresponding fields of the states

    for node_id in nodes:
        if node_id in chartstate:
            label = nodes[node_id].label or ''
            try:
                parseStateLabel(label, chartstate[node_id])
            except ChartException as m:
                msgs.extend(m.msgs)
        elif node_id not in pseudostate:
            msgs.append(Error('Orphan node', node_id))

    if len(msgs) > 0:
        raise ChartMessages(*msgs)
    return StatesManifest(root, Basic, Xor, And, chartstate)

```
</div>

</div>



VERSION USING PARENT FIELD

The state hierarchy is built by
- picking an `xor` node that has not been visited so far and creating a corresponding Basic state,
- starting with that node, following the `parent`, creating corresponding states, setting the `children` field of those, until the `root` state or a visited state is reached. If a visited state is reached, check if that is on the path of states visited, to detect a cycle, and turn it into an Xor state if it was Basic
- parsing all node labels and setting the corresponding fields of the states.

As expressions in state labels may contain state tests, these state tests can only be resolved after the state hierarchy is built, hence all state labels are parsed as the last step. For nodes of `xor` type, initially a Basic state is create. If that state is later found to have children, it is converted to an Xor state. For `and` nodes, an And state is created. Following checks are performed on the nodes while building the state hierarchy:
- A state with id `root` must be defined among the nodes.
- Each nodes must have a `parent` fields and that `parent` node must be defined.
- The relation among nodes given by the `parent` field must not be cyclic.
- Each node must have a `type` field that must be one `init`, `prob`, `cond`, `xor`, `and`.
- Nodes of `init`, `prob`, `cond` type must have `xor` parents.

Additionally, Basic and And states must have Xor parents in the resulting chart. This implies that the root state must be an Xor state, if the chart is not empty.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
# def buildStates(nodes: 'map id to node') -> 'root, Basic, Xor, And, chartstate':
#     """modifies msg"""

#     # 1. create the root state from the `root` node

#     if 'root' not in nodes: raise Error("No 'root' node defined") # can't continue
#     root = State('root', None) # id is 'root', no parent

#     # 2. repeatedly create states for all the children of the nodes visited so far;
#     #    classify the created states as Basic, Xor, And

#     Basic, Xor, And = set(), set(), set()
#     chartstate = {}  # map id to State
#     visit = {root}   # set of states to visit
#     for nid in nodes:
#         if 'parent' in nodes[nid] and nodes[nid]['parent'] in nodes:
#             pid = nodes[nid]['parent']
#             if pid in nodes:
#                 if 'type' in nodes[cid]:
#                     tp = nodes[cid]['type']
#                     if tp in ('xor', 'and'):
#                         s = State(nid, s)
#                     else: msg.append(Error("State type must be one of 'xor', 'and', 'init', 'prob', 'cond'", nid))
#                 else: msg.append(Error('Missing type', nid))
#             else: msg.append(Error("Missing 'parent' definition"))
#         else: msg.append(Error("Missing 'parent' field", nid))
#     while len(visit) > 0:
#         s = visit.pop()             # pick an arbirary state
#         if s.id in chartstate:      # already visited
#             raise Error('Child relation is cyclic', s.id) # can't continue
#         chartstate[s.id], n = s, nodes[s.id]    # n is the node corresponding to s
#         if 'children' in n:
#             for cid in n['children']:   # child id
#                 if cid in nodes:
#                     if 'type' in nodes[cid]:
#                         ctp = nodes[cid]['type'] # child type
#                         if ctp in ('and', 'xor'): s.children.add(State(cid, s))
#                         elif ctp in ('init', 'prob', 'cond'):
#                             pseudostate.add(cid)
#                             if n['type'] != 'xor':
#                                 msg.append(Error('Parent must be Xor state', cid))
#                         else: msg.append(Error('State type must be one of "xor", "and", \
#                                 "init", "prob", "cond"', cid))
#                     else: msg.append(Error('Missing type', cid))
#                 else: msg.append(Error('Missing child definition', cid))
#         if n['type'] == 'and':
#             if s.parent in Xor: And.add(s)
#             else: msg.append(Error('And state must have Xor parent', s.id))
#         elif len(s.children) == 0: # node type is xor, no children
#             if s.parent in Xor: Basic.add(s)
#             else: msg.append(Error('Basic state must have Xor parent', s.id))
#         else: Xor.add(s)
#         visit.update(s.children)

#     # 3. parsing all state labels and setting the corresponding fields of the states

#     for nid in nodes:
#         if nid in chartstate:
#             label = nodes[nid]['label'] if 'label' in nodes[nid] else ''
#             try: parseStateLabel(label, chartstate[nid])
#             except Exception as m: msg.extend(m.args)
#         elif nid not in pseudostate: msg.append(Error('Orphan node', nid))
#     return root, Basic, Xor, And, chartstate

```
</div>

</div>



Following checks are performed:
- source and target of every connection is defined
- root is not source or target of any connection
- `init`, `prob`, `cond` states have at least one outgoing connection
- `init` states cannot have incoming connections
- connections leaving an `init` state can only go to a sibling
- connections leaving an `init` state can only go to proper states
- connections leaving a proper, P, C state can only go to the parent, a sibling, a child
- connections leaving a P state can only go to C or proper states
- connections leaving a C state can only go to proper states

The auxiliary dictionary `outgoing`, mapping all states to the while doing so, construct incoming, outgoing to allow above check




<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
NodeId = Text
ConnectionId = Text
def buildTransitions(nodes: Mapping[Text, StateProxy], connections: Mapping[Text, ConnectionProxy], states_manifest: StatesManifest) -> List[Transition]:
    msgs = []  # collect error messages
    outgoing: MutableMapping[NodeId, MutableSet[ConnectionId]] = {}  # maps node id (of proper or pseudo state) to outgoing connection
    incoming = set()  # set of all nodes with incoming connections

    def buildCondChoices(source_id: NodeId) -> Set[Conditional]:  # uses nodes, chartstate, outgoing
        if nodes[source_id].type == StateType.CHOICE:
            if len(outgoing[source_id]) <= 0:
                raise Error('Ⓒ must have outgoing connection', source_id)

            choices = set()
            for conn_id in outgoing[source_id]:
                conn = connections[conn_id]

                guard, body = parseCondConnectionLabel(conn.label or '', conn_id)
                target = states_manifest.directory[conn.target]

                choices.add(Conditional(guard, body, target))
        else:
            choices = {Conditional(True, skip, states_manifest.directory[source_id])}

        return choices

    def buildProbAlternatives(source_id: NodeId) -> Sequence[Alternative]:  # uses nodes, outgoing
        if nodes[source_id].type == 'prob':
            if len(outgoing[source_id]) <= 0:
                raise Error('Ⓟ must have outgoing connection', source_id)

            alternatives = []
            for conn_id in outgoing[source_id]:
                conn = connections[conn_id]

                prob, body = parseProbConnectionLabel(conn.label, conn_id)
                choices = buildCondChoices(conn.target)

                alternatives.append(Alternative(prob, body, choices))
        else:
            alternatives = [Alternative(Fraction(1), skip, buildCondChoices(source_id))]

        return alternatives

    for conn_id, conn in connections.items():  # check if source and target are defined
        if conn.source is None or conn.target is None:
            msgs.append(Error('"source" and "target" are required', conn_id))
            continue

        outgoing.setdefault(conn.source, set()).add(conn_id)
        incoming.add(conn.target)

        if conn.source not in nodes:
            msgs.append(Error('Source "%s" undefined' % conn.source, conn_id))
            continue
        elif conn.target not in nodes:
            msgs.append(Error('Target "%s" undefined' % conn.target, conn_id))
            continue

        if conn.source == 'root':
            msgs.append(Error('Source cannot be root', conn_id))
            continue
        elif conn.target == 'root':
            msgs.append(Error('Target cannot be root', conn_id))
            continue

        source = nodes[conn.source]; target = nodes[conn.target]

        if target.type == StateType.INIT:
            msgs.append(Error('Must not target •', conn_id))

        if source.type == StateType.INIT:
            if source.parent != target.parent:
                msgs.append(Error('Target must be a sibling of its source', conn_id))

            if target.type not in (StateType.AND, StateType.XOR):
                msgs.append(Error('Target must be a proper state', conn_id))
        else:  # source is proper, P, C state
            if source.parent != target.parent and source.parent != conn.target and conn.source != target.parent:
                msgs.append(Error('Must go to sibling, parent, or child of its source', conn_id))

            if source.type == StateType.PROB and target.type not in (StateType.CHOICE, StateType.XOR, StateType.AND):
                msgs.append(Error('Target must be one of Ⓒ, Basic, And, Xor', conn_id))
            elif source.type == StateType.CHOICE and target.type not in (StateType.XOR, StateType.AND):
                msgs.append(Error('Target must be one of Basic, And, Xor', conn_id))

    transitions = []  # builds transitions and ...
    for conn_id, conn in connections.items():  # ... checks that P, C nodes have at least one outgoing connection
        try:
            source = nodes[conn.source]
            if source.type in (StateType.XOR, StateType.AND):
                event, guard, cost, body = parseFirstConnectionLabel(conn.label or '', conn_id)
                alts = buildProbAlternatives(conn.target)  # set
                transitions.append(Transition(conn_id, states_manifest.directory[conn.source], event, guard, cost, body, alts))
            elif source.type == StateType.INIT:
                p = states_manifest.directory[source.parent]
                guard, body = parseCondConnectionLabel(conn.label or '', conn_id)
                p.init.add(Conditional(guard, body, states_manifest.directory[conn.target]))
        except ChartException as m:
            msgs.extend(m.msgs)

    # check P, C nodes and states with siblings for incoming connection

    for n in set(nodes.keys()).difference(incoming):  # all nodes without incoming connection
        node = nodes[n]
        if node.type == StateType.PROB:
            msgs.append(Error('Ⓟ must have incoming connection', n))
        elif node.type == StateType.CHOICE:
            msgs.append(Error('Ⓒ must have incoming connection', n))
        elif node.type in (StateType.XOR, StateType.AND):  # states that are not sole child should ...
            # ... have an incoming connection, except root, which does not have
            parent_node = nodes.get(node.parent)  # None if root
            if n != 'root' and parent_node.type == StateType.XOR and len(parent_node.children) > 1:
                msgs.append(Error('Must have incoming connection', n))

    if len(msgs) > 0: raise ChartMessages(*msgs)
    return transitions

```
</div>

</div>



Validating a state graph and generating intermediate code proceeds in three steps:
- building the state hierarchy from the nodes,
- building the transitions from the connections,
- generating intermediate code.

The implementation below additionally:
- creates an auxiliary dictionary `chartstates` mapping ids to states,
- checks that `nodes` and `connections` are defined in `stategraph`,
- continues with the next step only if the previous step did not result in errors.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
class ChartManifest(NamedTuple):
    root: State
    Basic: MutableSet[State]
    Xor: MutableSet[State]
    And: MutableSet[State]
    transitions: Sequence[Transition]

def inflate(stategraph: MutableMapping[Text, AnyJson]) -> ChartManifest:
    chart_proxy = ChartProxy(stategraph)
    nodes = chart_proxy.states
    state_manifest = buildStates(nodes)
    connections = chart_proxy.connections
    transitions = buildTransitions(nodes, connections, state_manifest)
    return ChartManifest(*state_manifest[:4], transitions=transitions)

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
# from pstate import *

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
# pChart = PChartWidget()

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
# %%pstate_compile pChart
{
    "states": {
        "a": {
            "type": "xor",
            "id": "a",
            "children": {},
            "name": "A",
            "label": "Some code",
            "position": {
                "x": 10,
                "y": 30
            },
            "dimensions": {
                "width": 100,
                "height": 75
            }
        },
        "b": {
            "type": "xor",
            "id": "b",
            "children": {},
            "name": "B",
            "label": "Some other code",
            "position": {
                "x": 200,
                "y": 300
            },
            "dimensions": {
                "width": 100,
                "height": 75
            }
        },
        "c": {
            "type": "init",
            "id": "c",
            "position": {
                "x": 200,
                "y": 100
            },
            "radius": 10
        },
        "d": {
            "type": "prob",
            "id": "d",
            "position": {
                "x": 200,
                "y": 200
            },
            "radius": 20
        },
        "e": {
            "type": "choice",
            "id": "e",
            "position": {
                "x": 300,
                "y": 200
            },
            "radius": 40
        }
    },
    "connections": {
        "t_1": {
            "id": "t_1",
            "source": "a",
            "target": "b",
            "label": "event"
        },
        "t_2": {
            "id": "t_2",
            "source": "d",
            "target": "a",
            "label": "@0.9"
        },
        "t_3": {
            "id": "t_3",
            "source": "d",
            "target": "b",
            "label": "@0.1"
        },
        "t_4": {
            "id": "t_4",
            "source": "c",
            "target": "a",
            "comment": "Initial state is a"
        },
        "t_5": {
            "id": "t_5",
            "source": "b",
            "target": "d"
        }
    }
}

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
# pChart.value

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
# from IPython.display import display
# import ipywidgets as widgets
# int_range = widgets.IntSlider()
# display(int_range)

# def on_value_change(change):
#     print(change['new'])

# int_range.observe(on_value_change, names='value')

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
# p = pChart('chartfile'); p ; q = pView(p, 'T') ; q ; p.compileC('T', 'Cfile')

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
"""
# VERSION CREATING PSEUDO CHART STATES
def inflate(rawchart):
    global Root, Basic, XOR, AND, Init, Prob, Cond, chartstate, incoming, outgoing, Trans

    msg = [] # for collecting messages

    # 1. traverse all raw states to form tree with id, parent, children fields,
    #    starting with "root"; determine state Root and sets Basic, XOR, AND

    rawstates = rawchart.get('states', set()) # raw states, empty set if not defined
    if 'root' not in rawstates: return error('No "root" state defined') # can't continue
    Root = State(None, 'root')  # no parent, id "root"
    Basic, XOR, AND, Init, Prob, Cond = set(), set(), set(), set(), set(), set()
    chartstate = {}             # maps id of raw state to chart state
    incoming, outgoing = {}, {} # maps chart state to incoming, outgoing connection ids
    visit = {Root}              # set of chart states to visit
    while len(visit) > 0:
        cs = visit.pop()        # pick an arbirary chart state
        if cs.id in chartstate:
            return error('Child relation is cyclic', ('state', cs.id)) # can't continue
        chartstate[cs.id] = cs
        incoming[cs], outgoing[cs] = set(), set()
        rs = rawstates[cs.id] # rs is the corresponding raw state
        rt = rs['type'] if 'type' in rs else None          # raw type, None if not defined
        rc = rs['children'] if 'children' in rs else set() # raw children, empty set if not defined
        if rt == 'and':
            if cs.parent in XOR: AND.add(cs)
            else: msg.append(error('AND state must have XOR parent', ('state', cs.id)))
        elif rt == 'xor':
            if len(rc) == 0:
                if cs. parent in XOR: Basic.add(cs)
                else: msg.append(error('Basic state must have XOR parent', ('state', cs.id)))
            else: XOR.add(cs)
        elif rt == 'init':
            if cs.parent in XOR: Init.add(cs)
            else: msg.append(error('Parent of • must be XOR state', ('state', cs.id)))
        elif rt == 'prob':
            if cs.parent in XOR: Prob.add(cs)
            else: msg.append(error('Parent of Ⓟ ℗ must be XOR state', ('state', cs.id)))
        elif rt == 'cond':
            if cs.parent in XOR: Cond.add(cs)
            else: msg.append(error('Parent of Ⓒ © must be XOR state', ('state', cs.id)))
        else: msg.append(error('State type must be one of "xor", "and", "init", "prob", "cond"',
                               ('state', cs.id)))
        cs.children = set()
        for r in rc:
            if r in rawstates: cs.children.add(State(cs, r))
            else: msg.append(error('Missing child definition', ('state', r)))
        visit.update(cs.children)

    if Root not in XOR:
        msg.append(error('Root must be XOR state', ('state', Root.id)))

    for rs in rawstates.keys() - chartstate.keys():
        msg.append(error('Orphan state', ('state', rs)))

    # 2. traverse all chart states to parse the label, setting the name, variables/decls,
    #    event, inv, cost fields of each state

    visit = {Root} # set of chart states to visit
    while len(visit) > 0:
        cs = visit.pop()
        rs = rawstates.get(cs.id, {})
#        try:
        parseStateLabel(rs.get("label", ""), cs)
#        except Exception as m: msg.extend(m.args)
        visit.update(cs.children)

    # 3. traverse all connections and build maps incoming, outgoing:
    #   - incoming  maps every chart state to its set of incoming connection ids
    #   - outgoing  maps every chart state to its set of outgoing connection ids

    connections = rawchart.get("connections", set()) # connections or empty set if not defined
    for cid in connections:
        rc = connections[cid]
        if 'source' in rc:
            rs = rc['source']
            if rs in chartstate:
                outgoing[chartstate[rs]].add(cid)
            else: msg.append(error('Source not a state', ('connection', cid)))
        else: msg.append(error('"source" undefined', ('connection', cid)))
        if 'target' in rc:
            rt = rc["target"]
            if rt in chartstate: incoming[chartstate[rt]].add(cid)
            else: msg.append(error('Target not a state', ('connection', cid)))
        else: msg.append(error('"target" undefined', ('connection', cid)))

    # 4. check that
    #   - init states have no incoming connection
    #   - P, C states have at least one incoming connection
    #   - init, P, C states have at least one outgoing connection

    for cs in Init:
        for cid in incoming[cs]:
            msg.append(error('Must not target •', ('connection', cid)))
    for cs in Prob | Cond:
        if len(incoming[cs]) == 0:
            msg.append(error('Must have incoming connection', ('state', cs.id)))
    for cs in Init | Prob | Cond:
        if len(outgoing[cs]) == 0:
            msg.append(error('Must have outgoing connection', ('state', cs.id)))

    # 4. NEW check that
    #   - Root is not source or target of any connection
    #   - init, P, C states have at least one outgoing connection
    #   - init states cannot have incoming connections
    #   - connections leaving an init can only go to a sibling
    #   - connections leaving an init state can only go to proper states
    #   - connections leaving a P state can only go to C or proper statea
    #   - connections leaving a C state can only go to proper statea
    #   - connections leaving a proper, P, C state can only go to the parent, a sibling, a child

    if len(msg) > 0: return msg

    # 5. construct a transition for every connection leaving a proper state

    Trans = [] # set of all transitions
    for s0 in Basic | XOR | AND: # s0 ranges over proper chart states
        for cid1 in outgoing[s0]: # cid1 ranges over ids of connections leaving s0
#            try: # first create transition, parse and check label
                tr = Transition(s0); c1 = connections[cid1]
                lab = c1['label'] if 'label' in c1 else ''
                tr.kind, tr.guard, tr.cost, tr.body = parseFirstConnectionLabel(lab, s0, cid1)
                s1 = chartstate[c1['target']] # target is P, C, proper state
                msg.extend(checkWellScoped(s0, s1, cid1))
                if s1 in Prob: # add probabilistic alternatives to tr.target
                    alternatives = [] # set of all alternatives
                    for cid2 in outgoing[s1]:
                        c2 = connections[cid2]
                        # check no event/time, no guard, no cost
                        lab = c2['label'] if 'label' in c2 else ''
                        prob, body = parseProbConnectionLabel(lab, s0, cid2)
                        s2 = chartstate[c2["target"]]
                        msg.extend(checkWellScoped(s1, s2, cid2))
                        alternatives.append([prob, body, s2])
                else: alternatives = [[1, skip, s1]]
                msg.extend(checkProbsSumToOne(alternatives, s1))
                tr.target = alternatives
                for alt in alternatives:
                    s2 = alt[2]
                    if s2 in Cond:
                        conditionals = []
                        for cid3 in outgoing[s2]:
                            c3 = connections[cid3]
                            lab = c3['label'] if 'label' in c3 else ''
                            # CHECK IF s0 IS THE APPROPRIATE SCOPE(yes?)
                            guard, body = parseCondConnectionLabel(lab, s0, cid3)
                            # check that target is proper state and is or has same parent as source
                            s3 = chartstate[c3["target"]]
                            if s3 not in Basic | AND | XOR:
                                msg.append(error('Target must be one of: Basic, AND, OR'), cid3)
                            msg.extend(checkWellScoped(s2, s3, cid3))
                            conditionals.append([guard, body, s3])
                    else:
                        if s2 in Prob:
                            msg.append(error('Target must be one of: Basic, AND, OR, Ⓒ'), \
                                       ('connection', cid2))
                        conditionals = [[True, skip, s2]]
                    msg.extend(checkCompleteDisjoint(conditionals, s2))
                    alt[2] = conditionals
                Trans.append(tr)
#            except Exception as m: msg.extend(m.args)

    # 6. set default of XOR states

    for i0 in Init:
        if i0.parent not in XOR: msg.append(error('Init must be child of XOR state', ))
        conditionals = set()
        for cid in outgoing[i0]:
            c = connections[cid]
            # parse label, check no event/time, no probability, no cost
            lab = c['label'] if 'label' in c else ''
            # CHECK IF i0.parent IS THE APPROPRIATE SCOPE
            guard, body = parseCondConnectionLabel(lab, i0.parent, cid)
            # check that target is proper state and is child of parent
            i1 = chartstate[c["target"]]
            if i1 not in Basic | AND | XOR:
                msg.append(error('Target must be Basic, AND, OR state'), cid)
            if i0.parent != i1.parent:
                msg.append(error('Invalid target'), cid)
            conditionals.add((guard, body, i1))
        checkCompleteDisjoint(conditionals, i0.id)
        i0.parent.default = conditionals
"""

```
</div>

</div>



## Alternative Implementations



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
"""
# VERSION NOT CREATING PSEUDO CHART STATES

def inflate(rawchart):
    global Root, Basic, XOR, AND, Init, Prob, Cond, chartstate, incoming, outgoing, Trans

    msg = [] # for collecting messages

    # 1. traverse all raw states to form tree with id, parent, children fields,
    #    starting with "root"; determine state Root and sets Basic, XOR, AND

    rawstates = rawchart['states'] if 'states' in rawchart else set() # raw states, empty set if not defined
    if 'root' not in rawstates: return Error('No "root" state defined') # can't continue
    Root = State(None, 'root')  # no parent, id 'root'
    Basic, XOR, AND  = set(), set(), set() # sets of chart states
    Init, Prob, Cond = set(), set(), set() # sets of state ids
    chartstate = {}                        # maps state id to chart state
    incoming, outgoing = {}, {}            # maps state id to connection ids
    visit = {Root}                         # set of chart states to visit
    while len(visit) > 0:
        cs = visit.pop()        # pick an arbirary chart state
        if cs.id in chartstate:
            return Error('Child relation is cyclic', ('state', cs.id)) # can't continue
        chartstate[cs.id] = cs
        incoming[cs.id], outgoing[cs.id] = set(), set()
        rs = rawstates[cs.id]   # rs is the corresponding raw state
        rc = rs['children'] if 'children' in rs else set() # raw children, empty set if not defined
        if len(rc) == 0:
            if cs.parent in XOR: Basic.add(cs)
            else: msg.append(Error('Basic state must have XOR parent', ('state', cs.id)))
        else: XOR.add(cs)
        cs.children = set()
        for r in rc:
            if r in rawstates:
                rs = rawstates[r]
                rt = rs['type'] if 'type' in rs else None
                if rt in ('and', 'xor'):
                    cs.children.add(State(cs, r))
                    if rt == 'and' and cs not in XOR:
                        msg.append(Error('AND state must have XOR parent', ('state', cs.id)))
                elif rt in ('init', 'prob', 'cond'):
                    if cs not in XOR:
                        msg.append(Error('Must have XOR parent', ('state', cs.id)))
                if rt == 'and':
                    if cs in XOR: AND.add(cs)
                    else: msg.append(Error('AND state must have XOR parent', ('state', cs.id)))
        elif rt == 'xor':
        elif rt == 'init':
            if cs.parent in XOR: Init.add(cs)
            else: msg.append(Error('Parent of • must be XOR state', ('state', cs.id)))
        elif rt == 'prob':
            if cs.parent in XOR: Prob.add(cs)
            else: msg.append(Error('Parent of Ⓟ ℗ must be XOR state', ('state', cs.id)))
        elif rt == 'cond':
            if cs.parent in XOR: Cond.add(cs)
            else: msg.append(Error('Parent of Ⓒ © must be XOR state', ('state', cs.id)))
        else: msg.append(Error('State type must be one of "xor", "and", "init", "prob", "cond"',
                               ('state', cs.id)))
                cs.children.add(State(cs, r))
  #          else: msg.append(Error('Missing child definition', ('state', r)))
        visit.update(cs.children)

    if Root not in XOR:
        msg.append(Error('Root must be XOR state', ('state', Root.id)))

    for rs in rawstates.keys() - chartstate.keys():
        msg.append(Error('Orphan state', ('state', rs)))

    # 2. traverse all chart states to parse the label, setting the name, variables/decls,
    #    event, inv, cost fields of each state

    visit = {Root} # set of chart states to visit
    while len(visit) > 0:
        cs = visit.pop()
        rs = rawstates.get(cs.id, {})
#        try:
        parseStateLabel(rs.get("label", ""), cs)
#        except Exception as m: msg.extend(m.args)
        visit.update(cs.children)

    # 3. traverse all connections and build maps incoming, outgoing:
    #   - incoming  maps every chart state to its set of incoming connection ids
    #   - outgoing  maps every chart state to its set of outgoing connection ids

    connections = rawchart.get("connections", set()) # connections or empty set if not defined
    for cid in connections:
        rc = connections[cid]
        if 'source' in rc:
            rs = rc['source']
            if rs in chartstate:
                outgoing[chartstate[rs]].add(cid)
            else: msg.append(Error('Source not a state', ('connection', cid)))
        else: msg.append(Error('"source" undefined', ('connection', cid)))
        if 'target' in rc:
            rt = rc["target"]
            if rt in chartstate: incoming[chartstate[rt]].add(cid)
            else: msg.append(Error('Target not a state', ('connection', cid)))
        else: msg.append(Error('"target" undefined', ('connection', cid)))

    # 4. check that
    #   - init states have no incoming connection
    #   - P, C states have at least one incoming connection
    #   - init, P, C states have at least one outgoing connection

    for cs in Init:
        for cid in incoming[cs]:
            msg.append(Error('Must not target •', ('connection', cid)))
    for cs in Prob | Cond:
        if len(incoming[cs]) == 0:
            msg.append(Error('Must have incoming connection', ('state', cs.id)))
    for cs in Init | Prob | Cond:
        if len(outgoing[cs]) == 0:
            msg.append(Error('Must have outgoing connection', ('state', cs.id)))

    # 4. NEW check that
    #   - Root is not source or target of any connection
    #   - init, P, C states have at least one outgoing connection
    #   - init states cannot have incoming connections
    #   - connections leaving an init can only go to a sibling
    #   - connections leaving an init state can only go to proper states
    #   - connections leaving a P state can only go to C or proper states
    #   - connections leaving a C state can only go to proper statea
    #   - connections leaving a proper, P, C state can only go to the parent, a sibling, a child

    #   - check for undefined pseudostates, orphan pseudostates
    #   while doing so, construct incoming, outgoing to allow above check

    if len(msg) > 0: return msg

    # 5. construct a transition for every connection leaving a proper state

    Trans = [] # set of all transitions
    for s0 in Basic | XOR | AND: # s0 ranges over proper chart states
        for cid1 in outgoing[s0]: # cid1 ranges over ids of connections leaving s0
#            try: # first create transition, parse and check label
                tr = Transition(s0); c1 = connections[cid1]
                lab = c1['label'] if 'label' in c1 else ''
                tr.kind, tr.guard, tr.cost, tr.body = parseFirstConnectionLabel(lab, s0, cid1)
                s1 = chartstate[c1['target']] # target is P, C, proper state
                msg.extend(checkWellScoped(s0, s1, cid1))
                if s1 in Prob: # add probabilistic alternatives to tr.target
                    alternatives = [] # set of all alternatives
                    for cid2 in outgoing[s1]:
                        c2 = connections[cid2]
                        # check no event/time, no guard, no cost
                        lab = c2['label'] if 'label' in c2 else ''
                        prob, body = parseProbConnectionLabel(lab, s0, cid2)
                        s2 = chartstate[c2["target"]]
                        msg.extend(checkWellScoped(s1, s2, cid2))
                        alternatives.append([prob, body, s2])
                else: alternatives = [[1, skip, s1]]
                msg.extend(checkProbsSumToOne(alternatives, s1))
                tr.target = alternatives
                for alt in alternatives:
                    s2 = alt[2]
                    if s2 in Cond:
                        conditionals = []
                        for cid3 in outgoing[s2]:
                            c3 = connections[cid3]
                            lab = c3['label'] if 'label' in c3 else ''
                            # CHECK IF s0 IS THE APPROPRIATE SCOPE(yes?)
                            guard, body = parseCondConnectionLabel(lab, s0, cid3)
                            # check that target is proper state and is or has same parent as source
                            s3 = chartstate[c3["target"]]
                            if s3 not in Basic | AND | XOR:
                                msg.append(Error('Target must be one of: Basic, AND, OR'), cid3)
                            msg.extend(checkWellScoped(s2, s3, cid3))
                            conditionals.append([guard, body, s3])
                    else:
                        if s2 in Prob:
                            msg.append(Error('Target must be one of: Basic, AND, OR, Ⓒ'), \
                                       ('connection', cid2))
                        conditionals = [[True, skip, s2]]
                    msg.extend(checkCompleteDisjoint(conditionals, s2))
                    alt[2] = conditionals
                Trans.append(tr)
#            except Exception as m: msg.extend(m.args)

    # 6. set default of XOR states

    for i0 in Init:
        if i0.parent not in XOR: msg.append(Error('Init must be child of XOR state', ))
        conditionals = set()
        for cid in outgoing[i0]:
            c = connections[cid]
            # parse label, check no event/time, no probability, no cost
            lab = c['label'] if 'label' in c else ''
            # CHECK IF i0.parent IS THE APPROPRIATE SCOPE
            guard, body = parseCondConnectionLabel(lab, i0.parent, cid)
            # check that target is proper state and is child of parent
            i1 = chartstate[c["target"]]
            if i1 not in Basic | AND | XOR:
                msg.append(Error('Target must be Basic, AND, OR state'), cid)
            if i0.parent != i1.parent:
                msg.append(Error('Invalid target'), cid)
            conditionals.add((guard, body, i1))
        checkCompleteDisjoint(conditionals, i0.id)
        i0.parent.default = conditionals
"""

```
</div>

</div>

