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

## Relevant Publications
1. {% reference ParkSekerinski18 %} \[[pdf](content/publications/ParkSekerinski18.pdf)\]
2. {% reference NokovicSekerinski17 %} \[[pdf](content/publications/NokovicSekerinski17.pdf)\]
3. {% reference NokovicSekerinski16 %} \[[pdf](content/publications/NokovicSekerinski16.pdf)\]
4. {% reference NokovicSekerinski15 %} \[[pdf](content/publications/NokovicSekerinski15.pdf)\]
5. {% reference NokovicSekerinski14 %} \[[pdf](content/publications/NokovicSekerinski14.pdf)\]
6. {% reference NokovicSekerinski13 %} \[[pdf](content/publications/NokovicSekerinski13.pdf)\]
7. {% reference Sekerinski08 %} \[[pdf](content/publications/Sekerinski08.pdf)\]
8. {% reference SekerinskiZurob01 %} \[[pdf](content/publications/SekerinskiZurob01.pdf)\]










<!-- 
[iState: A Statechart Translator](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.126.7754&rep=rep1&type=pdf)
[pState: A Probabilistic Statecharts Translator](https://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=6601339)
[Verification and Code Generation for Timed Transitions in pCharts](http://www.cas.mcmaster.ca/~nokovib/C3S2E2014extended.pdf)
[A Holistic Approach in Embedded System Development](https://arxiv.org/pdf/1508.03897.pdf)
[Automatically Quantitative Analysis and Code Generator for Sensor Systems: The Example of Great Lakes Water Quality Monitoring](https://s3.amazonaws.com/academia.edu.documents/46779034/NokovicSekerinski15GreatLakes.pdf?response-content-disposition=inline%3B%20filename%3DAutomatic_Quantitative_Analysis_and_Code.pdf&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWOWYYGZ2Y53UL3A%2F20190620%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20190620T131517Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=6bfd0dd40a3e96935c16460b695f9fcdc0c34b3fc14900c0cae013ba61c66338)
[A Notebook Format for the Holistic Design of Embedded Systems (Tool Paper)](https://arxiv.org/pdf/1811.10820.pdf)
[Verifying Statecharts with State Invariants](https://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=4492874) -->