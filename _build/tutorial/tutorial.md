---
interact_link: content/tutorial/tutorial.ipynb
kernel_name: python3
has_widgets: false
title: 'Tutorial'
prev_page:
  url: /intro
  title: 'Home'
next_page:
  url: /examples/examples
  title: 'Examples'
comment: "***PROGRAMMATICALLY GENERATED, DO NOT EDIT. SEE ORIGINAL FILES IN /content***"
---


# Welcome to pState

## What is pState?

pState is experimental software under development for the design, validation and formal verification of complex systems. Classical UML statecharts are extended with probabilistic transitions, costs/rewards, and state invariants. Probabilistic choice can be used to model randomized algorithms or unreliable systems.

This notebook is meant to be an introduction to pState and what it is capable of. After going through this tutorial, you should be familiar with pState and how you may use it for solving problems. This is **_NOT_** meant as a comprehensive guide.

You can start by simply running the cell below with `Shift + Enter` to set up the rest of the tutorial. Afterwards, continue to read and try the examples provided.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
from pstate import *
from IPython.display import display

```
</div>

</div>



### UI

First, take a second to run the cell below and you should see an empty chart.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("empty"))

```
</div>

</div>



If you click on the grid, editor tools will appear in the top left corner. Hover over some of these tools to read their descriptions. Get a feel for how the editor works because it will be the main mode of interaction for creating pCharts.

### Types of States

There are five state types, namely:

  1. XOR
  2. AND
  3. Initial
  4. Choice
  5. Probability

Running the cell below will display all of the states available in pState.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("states"))

```
</div>

</div>



As you can see, the XOR and AND states look the same. We will explain later the difference between them. Try resizing a state by selecting the `select` tool, clicking on the state, and dragging on the edge. Only XOR and AND states are resizeable.

The state labelled with a blue C is a choice _pseudostate_, the black circle is an initial _pseudostate_ and the state labelled with an orange P is a probability _pseudostate_.

### Transitions

Transitions are represented by the black arrows. Run the cell below and try connecting the initial state to the XOR state. Afterwards, try labelling the state by clicking on it while no tool is selected.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("transitions_intro"))

```
</div>

</div>



Transitions can be labelled, and these labels serve as _events_. Labels may have guard conditions, which are expressions that evaluate to a boolean value. An example of this is `[doorOpen = true]`. A transition with this label will be activated if it evaluates to true.

Another type of transition is a _timed_ transition. An example of this is `10 s`, which indicates it will take 10 seconds for this transition to be activated.

Lastly, an event can be indicated by giving the label an identifier, like `buttonPressed`, as seen below. 

Transition labels are more complex, and some more functionality will be shown in later cells.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("accessibility_door"))

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("smart_lightbulb"))

```
</div>

</div>



### Hierachical State Machines

XOR and AND states can be an _atomic_ state, _sub_state or a _super_state. In the previous example, the XOR state was atomic. Below is an example of hierarchical states. 
In this example:
  * A is an XOR super state 
  * B is both a substate of A and a superstate of C & D. 
  * C and D are both atomic states.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("hierarchy"))

```
</div>

</div>



### Concurrency

Observe the dashed line that separates states C & D. This indicates that B is an AND state, and states C & D are _orthogonal_. When the system is in state B, it is also in state C & D. These two states are interdependent.



### State invariants



Figure below gives a view of the pState graphical interface with the example of a TV set. The TV control activity is partitioned into two states, the Basic state Standby and the AND state Working. The initial state is Standby. When the chart is in Working state it is in both the Picture and Sound states. Within XOR state Picture the chart is in one of the Basic states WarmingUp or Displaying, within XOR state Sound, the system is in one of the Basic states Waiting, On, or Off. The invariant of Working is that whenever Picture is in Displaying, Sound must not be in Waiting, i.e. must be either in On or Off. The invariant of Sound states that the sound level lev must be between 1 and 10. The event power causes the chart to flip between Standby and Working, no matter in which substates of Working the chart is. The transition on event warm broadcasts event soundOn. The transition on events down can only be taken if lev > 1 and when taken, will decrement lev. The transition on power to Working sets Picture and Sound to the default initial states WarmingUp and Waiting and sets lev to 5.

