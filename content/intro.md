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
1. Park, S., & Sekerinski, E. (2018). A Notebook Format for the Holistic Design of Embedded Systems (Tool Paper). In Electronic Proceedings in Theoretical Computer Science (Vol. 284). https://doi.org/10.4204/EPTCS.284.7 \[[pdf](content/publications/ParkSekerinski18.pdf)\]
2. Nokovic, B., & Sekerinski, E. (2017). Analysis and Implementation of Embedded System Models: Example of Tags in Item Management Application. In Model-Implementation Fidelity in Cyber Physical System Design (pp. 175–199). https://doi.org/10.1007/978-3-319-47307-9_7 \[[pdf](content/publications/NokovicSekerinski17.pdf)\]
3. Nokovic, B., & Sekerinski, E. (2016). Automatically Quantitative Analysis and Code Generator for Sensor Systems: The Example of Great Lakes Water Quality Monitoring (Vol. 170, pp. 313–319). https://doi.org/10.1007/978-3-319-47075-7_35 \[[pdf](content/publications/NokovicSekerinski16.pdf)\]
4. Nokovic, B., & Sekerinski, E. (2015). A Holistic Approach in Embedded System Development. In Electronic Proceedings in Theoretical Computer Science (Vol. 187). https://doi.org/10.4204/EPTCS.187.6 \[[pdf](content/publications/NokovicSekerinski15.pdf)\]
5. Nokovic, B., & Sekerinski, E. (2014). Verification and Code Generation for Timed Transitions in pCharts. In ACM International Conference Proceeding Series. https://doi.org/10.1145/2641483.2641522 \[[pdf](content/publications/NokovicSekerinski14.pdf)\]
6. Nokovic, B., & Sekerinski, E. (2013). pState: A probabilistic statecharts translator (pp. 29–32). https://doi.org/10.1109/MECO.2013.6601339 \[[pdf](content/publications/NokovicSekerinski13.pdf)\]
7. Sekerinski, E. (2008). Verifying Statecharts with State Invariants. In Proceedings of the IEEE International Conference on Engineering of Complex Computer Systems, ICECCS (pp. 7–14). https://doi.org/10.1109/ICECCS.2008.40 \[[pdf](content/publications/Sekerinski08.pdf)\]
8. Sekerinski, E., & Zurob, R. (2001). iState: A Statechart Translator (Vol. 2185, pp. 376–390). https://doi.org/10.1007/3-540-45441-1_28 \[[pdf](content/publications/SekerinskiZurob01.pdf)\]

<!-- 
[iState: A Statechart Translator](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.126.7754&rep=rep1&type=pdf)
[pState: A Probabilistic Statecharts Translator](https://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=6601339)
[Verification and Code Generation for Timed Transitions in pCharts](http://www.cas.mcmaster.ca/~nokovib/C3S2E2014extended.pdf)
[A Holistic Approach in Embedded System Development](https://arxiv.org/pdf/1508.03897.pdf)
[Automatically Quantitative Analysis and Code Generator for Sensor Systems: The Example of Great Lakes Water Quality Monitoring](https://s3.amazonaws.com/academia.edu.documents/46779034/NokovicSekerinski15GreatLakes.pdf?response-content-disposition=inline%3B%20filename%3DAutomatic_Quantitative_Analysis_and_Code.pdf&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWOWYYGZ2Y53UL3A%2F20190620%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20190620T131517Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=6bfd0dd40a3e96935c16460b695f9fcdc0c34b3fc14900c0cae013ba61c66338)
[A Notebook Format for the Holistic Design of Embedded Systems (Tool Paper)](https://arxiv.org/pdf/1811.10820.pdf)
[Verifying Statecharts with State Invariants](https://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=4492874) -->