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

If you have not done so already (and you are not currently on mybinder.org), click the button at the top of the page labelled **Interact**. This will open an interactive session where you can run the cells.

You can start by simply running the cell below with `Shift + Enter` to set up the rest of the tutorial. Afterwards, continue to read and try the examples provided.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
from pstate import *
from IPython.display import display

```
</div>

</div>



---
## UI
First, take a second to run the cell below and you should see an empty chart. If you click on the grid, editor tools will appear in the top left corner. Hover over some of these tools to read their descriptions. Get a feel for how the editor works because it will be the main mode of interaction for creating pCharts.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("empty"))

```
</div>

</div>



---
## States

### Types of States
There are five state types, namely:

  1. XOR
  2. AND
  3. Initial
  4. Choice
  5. Probability

Running the cell below will display all of the states available in pState. The state labelled with a blue C is a choice _pseudostate_, the black circle is an initial _pseudostate_ and the state labelled with an orange P is a probability _pseudostate_.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("all_states"))

```
</div>

</div>



### Creating States
States can be created with the create `create` tool from the toolbar. Create an initial state followed by an XOR state.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("states"))

```
</div>

</div>



### Resizing States
States can be resized by selecting the `select` tool, clicking on the state, and dragging on the edge. Only XOR and AND states are resizeable. While creating states, you can click and drag to resize the state. Follow up on the previous exercise by resizing the XOR state to be a 4x4 square. 

**Note**: The design of pState allows for multiple instances of the same chart to be displayed. Modifications in one instance will modify the other instance.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("states"))

```
</div>

</div>



### Labelling States
XOR states and AND states can be labelled with an identifier. This is done by deselecting any tools, and clicking on the state you would like to label. Sibling states (states at the same level) cannot have the same name, and must differ by more than just case. Now that you've hopefully completed the previous task, you can now try labelling the XOR state with the label `S`.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("states"))

```
</div>

</div>



---
## Transitions
Transitions represent the change in state when a certain event occurs. Transitions are represented by the black arrows. Transitions connect a _source_ state to a _target_ state. Transitions are `fired` when the event labelling them occurs.

### Creating Transitions
Transitions can be create with the `create` tool. Dragging from the source to the target will create a connection between them. The transitions can be modified using the `select` tool. Connect the states you created earlier.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("states"))

```
</div>

</div>



### Labelling Transitions
Transitions can be labelled, like states, with an identifier. In the next section, the types of transitions will be explained. For now, making sure you have no tool selected, double click on the transition, and label it with the label `E`.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("states"))

```
</div>

</div>



### Event Transitions
Transitions can fire according to many different events. The first, and simplest, is firing on some event E. As an example, if the system is in state R, and event E occurs, the system will transition to state S.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("event_transitions"))

```
</div>

</div>



A simple example using just event transitions would be the following high-level chart representing a game of chess. The names of the events (in this case) are self explanatory. 



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("chess"))

```
</div>

</div>



### Timed Transitions
Timed transitions are transitions that are fired after a period of time. They can be formulated in different ways, which will be seen soon. The basic form is below. After 5 seconds being in state R, the transition will fire and the system will transition to state S.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("timed_transitions"))

```
</div>

</div>



Here is a simple example of an accessibility door, which will open for 10 seconds if the button is pressed, and will close afterwards. If at any point the button is pressed again, the door will open and the timer will reset.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("accessibility_door"))

```
</div>

</div>



If you want a transition to fire if there is an event also attached to the transition, you must use the `∆` symbol to tell pState that there is a timing associated with the transition. If the system is in state R for 5 seconds or event E occurs, the system will transition to state S.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("timed_transitions2"))

```
</div>

</div>



A simple example of this is a lightbulb. If the light is switched on or if movement is detected, it will switch on. The light will switch off if 1 hour elapses without detecting movement.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("smart_lightbulb"))

```
</div>

</div>



Some more advanced uses are as follows. The `..` represents a range. In the case of `..5s`, the transition will fire after 0 to 5 seconds, which is non-deterministic. In the case of `10s..20s`, the lower range and upper ranges are 10 and 20 seconds respectively. `unif(x, y)` is a timing which is uniformly distributed within the given range. `exp(t)` represents an exponential distribution of the timing.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("timed_transitions3"))

```
</div>

</div>



The next example is a toaster. While it is heating, it may take anywhere from 20 to 100 seconds to finish toasting the bread and to be ejected.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("toaster"))

```
</div>

</div>



### Guarded Transitions
Transition guards are boolean expressions which, if they evaluate to true, will cause the transition to be fired. In the case below, if the system is in state R, and expression E evaluates to true, the system will transition to state S. If E is false, then the system will not change state.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("guarded_transitions"))

```
</div>

</div>



### Actions
When a transition fires, a specified action can occur. They are in the form `/ Statement`. The basic actions are:
* Assignment statements
   * Assignment statements are of the form `x := y`. 
* Conditional statements
   * Conditional statements are of the form `if E then F else G`, where E is an expression, and F and G are statements.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("actions"))

```
</div>

</div>



---
## Hierachical State Machines

XOR and AND states can be an _atomic_ state, _sub_state or a _super_state. In the previous examples, the XOR states wereatomic. Below is an example of hierarchical states. 
In this example:
  * A is an XOR super state 
  * B is both a substate of A and a superstate of C & D. 
  * C and D are both atomic states.

Don't worry about the dashed line in the middle of state B, this will be explained in the next section.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("hierarchy"))

```
</div>

</div>



Transitions between states can only be between states who are siblings (same parent state) or between a parent state and its child. In each example below, the bottom example in the chart just illustrates how the hierarchical transition from above is interpreted, but they do **not** work in pState.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("transition_equivalents"))

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("transition_equivalents2"))

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("transition_equivalents3"))

```
</div>

</div>



If you remember the accessibility example from earlier, it was messy due to the repetition of transitions with the buttonPressed event. This can be solved using a hierarchical structure for the system. As a refresher, both the original and modified example will be shown below.



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
display(pChart("accessibility_door_modified"))

```
</div>

</div>



The following example describes a car transmission using a hierarchical structure. 



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("transmission"))

```
</div>

</div>



**Note**: individual states can be a chart, meaning you can the chart components can be drawn in different cells. Below is the previous example but drawn with the Forward state in a different chart.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("forward"))

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("transmission_only"))

```
</div>

</div>



---
## Concurrency
In a system, there may be multiple components that have their own state and act independently. Looking below, when in state R, the system will be in both states S and T. On top of this, if 



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("concurrency"))

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("concurrency_transitions")) # Not sure how to implement this

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("concurrency_transitions2")) # Not sure how to implement this

```
</div>

</div>



Using our car transmission example from before, we can extend it with a concurrent _ignition_ state.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("ignition"))

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("car"))

```
</div>

</div>



### Event Broadcasting
Events can be broadcast. In example below, if the system is in state S1, and event E occurs, the transition is fired, and the event F is broadcast. The transition from state T1 to T2 fires on the event F, so if event E occurs, this transition will fire too. 



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("event_broadcasting"))

```
</div>

</div>



---
## Local Variables
When labelling states, variables can be declared 



---
## State invariants



In this example, if ParkingSpaces is in state Empty, then there must also be 0 cars in Garage. If ParkingSpaces is in state Full, then there must be 10 cars in Garage. If Cleanliness is in the Dirty state, then there must be more than 100 units of dirt in Garage.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("garage"))

```
</div>

</div>



Below gives an example of a system with invariants. The TV control activity is partitioned into two states, Working and Standby. The initial state is Standby. When the chart is in the Working state, it is in both the Picture and Sound states. Within XOR state Picture, the chart is in one of the state WarmingUp or Displaying. Within XOR state Sound, the system is in one of the states Waiting, On, or Off. The invariant of Working is that whenever Picture is in Displaying, Sound must not be in Waiting, i.e. must be either in On or Off. The invariant of Sound states that the sound level _lev_ must be between 1 and 10. The event _power_ causes the chart to flip between Standby and Working, no matter in which substates of Working the chart is. The transition on event warm broadcasts event _soundOn_. The transition on events down can only be taken if lev > 1 and when taken, will decrement lev. The transition on power to Working sets Picture and Sound to the default initial states WarmingUp and Waiting and sets lev to 5.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("tv_set"))

```
</div>

</div>



---
## Conditions



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("conditionals"))

```
</div>

</div>



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("temperature_monitor"))

```
</div>

</div>



---
## Costs & Rewards
Costs can be associated with both states and transitions.



---
## Probability

Some systems require probabilities to be attached to certain transitions. The probability pseudostate can only be the source of transitions with probabilities attached. Running through the example below, if the system is in state Q and event E occurs, there is a 60% chance that the system will transition to state R, and a 40% chance that the system will transition to state S.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("probabilities"))

```
</div>

</div>



Below is an example of how this can be used to model a system with a sender and reciever.



<div markdown="1" class="cell code_cell">
<div class="input_area" markdown="1">
```python
display(pChart("sender_reciever"))

```
</div>

</div>

