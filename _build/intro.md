---
title: 'Home'
prev_page:
  url: 
  title: ''
next_page:
  url: https://mybinder.org/v2/gh/pstate/pstate.github.io/master?filepath=content/tutorial/tutorial.ipynb
  title: 'Tutorial'
comment: "***PROGRAMMATICALLY GENERATED, DO NOT EDIT. SEE ORIGINAL FILES IN /content***"
---
# Welcome to pState

## What is pState?

**pState** is experimental software toolkit under development for the design, validation and formal verification of complex systems. Classical statecharts are extended with probabilistic transitions, costs/rewards, and state invariants. Probabilistic choice can be used to model randomized algorithms or unreliable systems.

Costs/rewards can be used to compute quantitative properties such as expected power consumption or expected number of lost messages in model of some communication protocol. State invariants are used to express safety conditions or consistency constraints. The charts are validated and transformed into an intermediate representation, from which code for various languages is generated. The intention to generate code and temporal logic formulae for the probabilistic model checker PRISM for verifying invariants and calculating costs/rewards for the whole chart, and to generate executable C code for selected parts of the chart.

The current implementation of pState is a redevelopment with two goals:

1. to decouple the user interface from the analysis of charts by using modern Web-based techniques, such that the computationally intensive analysis can also run remotely, and
2. to simplify and generalize the implementation in order to ease further development, in particular for more code generators and alternative verification and quantitative analysis tools.

The current implementation consists of:

- a _web-based client_, maintained at https://gitlab.cas.mcmaster.ca/lime/pstate-client,
- the _core backend_, maintained at https://gitlab.cas.mcmaster.ca/lime/pstate-jupyter.

The user guide is documented elsewhere []('#'). This document, a Jupyter notebook, describes the core backend. This is an example of _literate development:_ the executable Python code for the backend is extracted from this notebook.

### pCharts

Variation of statecharts extended with probabilistic transitions, costs/rewards, and state invariants. Timed transitions with nondeterministic and stochastic timing can be used for the specification and analysis of real-time systems. 
